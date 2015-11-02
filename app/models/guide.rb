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

  def work_in_progress_edition?
    latest_edition.try(:published?) == false
  end

  def can_request_review?
    return false if latest_edition.nil?
    return false if !latest_edition.persisted?
    return false if latest_edition.review_requested?
    return false if latest_edition.published?
    return false if latest_edition.approved?
    true
  end

  def can_mark_as_approved?
    return false if latest_edition.nil?
    return false if !latest_edition.persisted?
    latest_edition.review_requested?
  end
end
