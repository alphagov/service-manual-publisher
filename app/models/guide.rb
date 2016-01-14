class Guide < ActiveRecord::Base
  validates :content_id, presence: true, uniqueness: true
  validate :slug_format
  validate :slug_cant_be_changed_if_an_edition_has_been_published

  has_many :editions
  has_one :latest_edition, -> { order(created_at: :desc) }, class_name: "Edition"

  accepts_nested_attributes_for :latest_edition
  scope :by_user, ->(user_id) { where(editions: { user_id: user_id }) if user_id.present? }
  scope :in_state, ->(state) { where(editions: { state: state }) if state.present? }
  scope :owned_by, ->(content_owner_id) { where(editions: { content_owner_id: content_owner_id }) if content_owner_id.present? }

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end

  def self.with_published_editions
    joins(:editions)
      .where(editions: { state: "published" })
      .uniq
  end

  def self.search(search_terms)
    words = sanitize(search_terms.scan(/\w+/) * "|")
    where("tsv @@ to_tsquery('pg_catalog.english', #{words})")
      .order("ts_rank_cd(tsv, to_tsquery('pg_catalog.english', #{words})) DESC")
  end

  def has_published_edition?
    editions.where(state: "published").any?
  end

  def work_in_progress_edition?
    latest_edition.try(:published?) == false
  end

  def comments_for_rendering
    latest_edition.comments.for_rendering
  end

  def ensure_draft_exists
    if latest_edition.published?
      editions << latest_edition.draft_copy
      reload
    end
    self
  end

  def latest_editable_edition
    return Edition.new unless latest_edition

    if latest_edition.published?
      latest_edition.draft_copy.tap do |e|
        e.update_type = "major"
      end
    else
      latest_edition
    end
  end

private

  def slug_format
    if !slug.to_s.match(/\A\/service-manual\//)
      errors.add(:slug, "must be present and start with '/service-manual/'")
    elsif !slug.to_s.match(/\A\/service-manual\/\w+/)
      errors.add(:slug, "must be filled in")
    elsif !slug.to_s.match(/\A\/service-manual\/[a-z0-9\-\/]+$/i)
      errors.add(:slug, "can only contain letters, numbers and dashes")
    end
  end

  def slug_cant_be_changed_if_an_edition_has_been_published
    if slug_changed? && has_published_edition?
      errors.add(:slug, "can't be changed if guide has a published edition")
    end
  end
end
