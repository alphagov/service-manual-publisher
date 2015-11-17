class Guide < ActiveRecord::Base
  validates :content_id, presence: true, uniqueness: true
  validates :slug, presence: true
  validates :slug, format: {
    with: /\A\/service-manual\//,
    message: "must be be prefixed with /service-manual/"
  }

  has_many :editions
  has_one :latest_edition, -> { order(created_at: :desc) }, class_name: "Edition"

  accepts_nested_attributes_for :editions

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end

  def self.with_published_editions
    joins(:editions)
      .where(editions: { state: "published" })
      .uniq
  end

  def work_in_progress_edition?
    latest_edition.try(:published?) == false
  end

  def comments_for_rendering
    latest_edition.comments.for_rendering
  end

  def latest_editable_edition
    return Edition.new unless latest_edition

    if latest_edition.published?
      latest_edition.dup.tap do |e|
        e.change_note = nil
        e.update_type = "minor"
      end
    else
      latest_edition
    end
  end
end
