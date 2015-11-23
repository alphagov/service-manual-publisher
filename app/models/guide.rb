class Guide < ActiveRecord::Base
  validates :content_id, presence: true, uniqueness: true
  validates :slug, presence: true
  validates :slug, format: {
    with: /\A\/service-manual\//,
    message: "must be be prefixed with /service-manual/"
  }

  has_many :editions
  has_one :latest_edition, -> { order(created_at: :desc) }, class_name: "Edition"

  accepts_nested_attributes_for :latest_edition

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end

  def self.with_published_editions
    joins(:editions)
      .where(editions: { state: "published" })
      .uniq
  end

  def self.search(search_terms)
    ids = Edition.search(search_terms).pluck(:guide_id)
    order = sanitize_sql_array(
      ["position(id::text in ?)", ids.join(',')]
    )
    where(:id => ids).order(order)
  end

  def self.with_state(state)
    Guide.includes(:latest_edition).where(editions: {state: state})
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
end
