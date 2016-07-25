class BaseGuideForm
  DEFAULT_UPDATE_TYPE = "major".freeze

  include ActiveModel::Model

  attr_reader :guide, :edition, :user
  attr_accessor :author_id, :body, :change_note, :change_summary, :content_owner_id, :description, :slug,
    :title, :title_slug, :type, :update_type, :version

  delegate :persisted?, to: :guide

  def self.build(**args)
    guide = args.fetch(:guide)

    if guide.is_a? Point
      PointForm.new(**args)
    else
      GuideForm.new(**args)
    end
  end

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
    self.title = edition.title
    self.title_slug = extracted_title_from_slug
    self.type = guide.type
    self.update_type = next_update_type
    self.version = next_edition_version

    load_custom_attributes

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
    edition.title = title
    edition.update_type = update_type
    edition.version = version

    set_custom_attributes

    catching_gds_api_exceptions do
      if valid? && guide.save
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

  def load_custom_attributes
    # optionally implemented in the concrete class
  end

  def set_custom_attributes
    # optionally implemented in the concrete class
  end

  def extracted_title_from_slug
    slug ? slug.split("/").last : nil
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
    ignored_attributes = [:editions]
    model.errors.each do |attrib, message|
      errors.add(attrib, message) unless ignored_attributes.include? attrib
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
    content_for_publication = GuidePresenter.new(guide, edition)
    PUBLISHING_API.put_content(content_for_publication.content_id, content_for_publication.content_payload)
    PUBLISHING_API.patch_links(content_for_publication.content_id, content_for_publication.links_payload)
  end
end
