class Guide < ApplicationRecord
  include ContentIdentifiable
  validate :slug_format
  validate :slug_cant_be_changed, if: :has_any_published_editions?
  validate :new_edition_has_content_owner, if: :requires_content_owner?
  validate :must_have_topic, if: :requires_topic?
  validate :topic_cannot_change, if: [:requires_topic?, :has_any_published_editions?]

  has_many :editions, dependent: :destroy
  has_many :topic_section_guides, dependent: :destroy, autosave: true

  scope :only_latest_edition, -> {
    joins(:editions)
      .where('editions.created_at = (SELECT MAX(editions.created_at) FROM editions WHERE editions.guide_id = guides.id)')
  }

  scope :in_state, ->(state) {
    only_latest_edition.where("editions.state = ?", state)
  }
  scope :by_author, ->(author_id) {
    only_latest_edition.where("editions.author_id = ?", author_id)
  }
  scope :owned_by, ->(content_owner_id) {
    only_latest_edition.where("editions.content_owner_id = ?", content_owner_id)
  }
  scope :by_type, ->(type) {
    if type.blank?
      where("type = '' OR type IS NULL")
    else
      where(type: type)
    end
  }

  delegate :title, to: :latest_edition

  def self.live
    where("EXISTS(#{editions_count_in_state_subquery('published').to_sql})")
      .not_unpublished
  end

  def self.not_unpublished
    where("NOT EXISTS(#{editions_count_in_state_subquery('unpublished').to_sql})")
  end

  def self.editions_count_in_state_subquery(state)
    from("editions")
      .where("editions.guide_id = guides.id")
      .where("editions.state = ?", state)
  end

  def self.search(search_terms)
    words = connection.quote(search_terms.scan(/\w+/) * "|")
    where("tsv @@ to_tsquery('pg_catalog.english', #{words})")
      .order("ts_rank_cd(tsv, to_tsquery('pg_catalog.english', #{words})) DESC")
  end

  def latest_edition_per_edition_group
    editions
      .select("DISTINCT ON (version) *")
      .order("version DESC, created_at DESC")
  end

  def latest_edition
    editions.most_recent_first.first
  end

  def live_edition
    latest_edition_to_update_the_frontend =
      editions.which_update_the_frontend.most_recent_first.first

    return nil if latest_edition_to_update_the_frontend.nil?
    return nil if latest_edition_to_update_the_frontend.unpublished?

    latest_edition_to_update_the_frontend
  end

  def topic
    Topic.includes(topic_sections: :guides)
      .references(:guides)
      .where("guides.id = ?", id)
      .first
  end

  def included_in_a_topic?
    topic.present?
  end

  def has_any_published_editions?
    editions.published.any?
  end

  def has_been_published?
    has_any_published_editions? && !has_any_unpublished_editions?
  end

  def editions_since_last_published
    latest_published_edition = editions.published.last
    return [] unless latest_published_edition.present?
    editions
      .where("created_at > ?", latest_published_edition.created_at)
  end

  def work_in_progress_edition?
    latest_edition.try(:published?) == false
  end

  def comments_for_rendering
    latest_edition.comments.for_rendering
  end

  def requires_content_owner?
    true
  end

  def requires_topic?
    true
  end

private

  def has_any_unpublished_editions?
    editions.unpublished.any?
  end

  def slug_format
    if !slug.to_s.match(/\A\/service-manual\/[a-z0-9\-\/]+$/i)
      errors.add(:slug, "can only contain letters, numbers and dashes")
    end

    if !slug.to_s.match(/\A\/service-manual\/[a-z0-9-]+\/[a-z0-9-]+/)
      errors.add(:slug, "must be present and start with '/service-manual/[topic]'")
    end
  end

  def slug_cant_be_changed
    if slug_changed?
      errors.add(:slug, "can't be changed as this guide has been published")
    end
  end

  def new_edition_has_content_owner
    new_edition = editions.detect(&:new_record?)

    if new_edition && new_edition.content_owner.nil?
      errors.add(:latest_edition, 'must have a content owner')
    end
  end

  def must_have_topic
    if topic_section_guides.empty?
      errors.add(:topic_section, "can't be blank")
    end
  end

  def topic_cannot_change
    topic_section_guide = topic_section_guides[0]

    return if topic_section_guide.blank?

    from, to = topic_section_guide.topic_section_id_change

    return if from.blank?

    old_section = TopicSection.find(from)
    new_section = TopicSection.find(to)

    if old_section.topic_id != new_section.topic_id
      errors.add(:topic_section, "can't be changed to a different topic as this guide has been published")
    end
  end
end
