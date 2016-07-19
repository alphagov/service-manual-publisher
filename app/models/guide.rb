class Guide < ActiveRecord::Base
  include ContentIdentifiable
  validate :slug_format
  validate :slug_cant_be_changed_if_an_edition_has_been_published
  validate :new_edition_has_content_owner, if: :requires_content_owner?

  has_many :editions, dependent: :destroy
  has_many :topic_section_guides, autosave: true

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
    where("EXISTS(#{editions_count_in_state_subquery('published').to_sql})").
    where("NOT EXISTS(#{editions_count_in_state_subquery('unpublished').to_sql})")
  end

  def self.editions_count_in_state_subquery(state)
    from("editions").
    where("editions.guide_id = guides.id").
    where("editions.state = ?", state)
  end

  def self.search(search_terms)
    words = sanitize(search_terms.scan(/\w+/) * "|")
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

  def has_published_edition?
    editions.where(state: "published").any?
  end

  def can_be_unpublished?
    has_published_edition? && !has_unpublished_edition?
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

private

  def has_unpublished_edition?
    editions.where(state: "unpublished").any?
  end

  def slug_format
    if !slug.to_s.match(/\A\/service-manual\/[a-z0-9\-\/]+$/i)
      errors.add(:slug, "can only contain letters, numbers and dashes")
    end

    if !slug.to_s.match(/\A\/service-manual\/[a-z0-9-]+\/[a-z0-9-]+/)
      errors.add(:slug, "must be present and start with '/service-manual/[topic]'")
    end
  end

  def slug_cant_be_changed_if_an_edition_has_been_published
    if slug_changed? && has_published_edition?
      errors.add(:slug, "can't be changed if guide has a published edition")
    end
  end

  def new_edition_has_content_owner
    new_edition = editions.detect(&:new_record?)

    if new_edition && new_edition.content_owner.nil?
      errors.add(:latest_edition, 'must have a content owner')
    end
  end
end
