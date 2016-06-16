class GuideForm
  DEFAULT_UPDATE_TYPE = "major".freeze

  include ActiveModel::Model

  attr_reader :guide, :edition, :user
  attr_accessor :author_id, :body, :change_note, :change_summary, :content_owner_id, :description, :slug,
    :summary, :title, :title_slug, :topic_section_id, :type, :update_type, :version

  validates_presence_of :topic_section_id
  validate :topic_cannot_change

  delegate :persisted?, to: :guide

  def initialize(guide:, edition:, user:)
    @guide = guide
    @edition = edition
    @user = user

    self.author_id = next_author_id
    self.body = edition.body
    self.change_note = edition.change_note
    self.change_summary = edition.change_summary
    self.content_owner_id = edition.content_owner_id
    self.description = edition.description
    self.slug = guide.slug
    self.summary = edition.summary
    self.title = edition.title
    self.title_slug = extracted_title_from_slug
    self.topic_section_id = topic_section.try(:id)
    self.type = guide.type
    self.update_type = next_update_type
    self.version = next_edition_version

    if edition.published?
      self.change_note = nil
      self.change_summary = nil
    end
  end

  def save
    guide.slug = slug
    edition.author_id = author_id
    edition.body = body
    edition.change_note = change_note
    edition.change_summary = change_summary
    edition.content_owner_id = content_owner_id
    edition.created_by_id = user.id
    edition.description = description
    edition.state = Edition::STATES.first
    edition.summary = summary
    edition.title = title
    edition.update_type = update_type
    edition.version = version
    topic_section_guide.topic_section_id = topic_section_id

    catching_gds_api_exceptions do
      if valid? && guide.save && topic_section_guide.save
        save_draft_to_publishing_api

        true
      else
        promote_errors_for(guide)
        promote_errors_for(edition)

        false
      end
    end
  end

  def to_param
    guide.id.to_s
  end

  def model_name
    ActiveModel::Name.new(Guide)
  end

  def assign_attributes(attributes)
    attributes.each do |k, v|
      send("#{k}=", v)
    end
  end

private

  def topic_section_guide
    @_topic_section_guide ||= TopicSectionGuide
      .includes(:topic_section)
      .references(:topic_section)
      .find_or_initialize_by(guide: guide)
  end

  def extracted_title_from_slug
    slug ? slug.split("/").last : nil
  end

  def topic_section
    TopicSection
      .joins(:topic_section_guides)
      .find_by('topic_section_guides.guide_id = ?', guide.id)
  end

  def next_edition_version
    if edition.published?
      edition.version + 1
    else
      edition.version || 1
    end
  end

  def next_update_type
    if edition.published?
      DEFAULT_UPDATE_TYPE
    else
      edition.update_type || DEFAULT_UPDATE_TYPE
    end
  end

  def next_author_id
    if edition.published?
      user.id
    else
      edition.author ? edition.author.id : user.id
    end
  end

  def promote_errors_for(model)
    model.errors.each do |attrib, message|
      errors.add(attrib, message)
    end
  end

  def topic_cannot_change
    from, to = topic_section_guide.topic_section_id_change

    return true if from.blank?

    old_section = TopicSection.find(from)
    new_section = TopicSection.find(to)

    if old_section.topic_id != new_section.topic_id
      errors.add(:topic_section_id, "cannot change to a different topic")
    end
  end

  def catching_gds_api_exceptions
    begin
      ActiveRecord::Base.transaction do
        yield
      end
    rescue GdsApi::HTTPErrorResponse => e
      errors.add(:base, e.error_details['error']['message'])

      false
    end
  end

  def save_draft_to_publishing_api
    content_for_publication = GuideFormPublicationPresenter.new(self)
    PUBLISHING_API.put_content(content_for_publication.content_id, content_for_publication.content_payload)
    PUBLISHING_API.patch_links(content_for_publication.content_id, content_for_publication.links_payload)
  end
end
