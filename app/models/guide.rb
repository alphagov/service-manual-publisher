class Guide < ActiveRecord::Base
  validates :content_id, presence: true, uniqueness: true
  validates :slug, presence: true
  validates :slug, format: {
    with: /\A\/service-manual\//,
    message: "must be be prefixed with /service-manual/"
  }

  def needs_review?
    latest_edition.draft? && latest_edition.review_request.present?
  end

  has_many :editions
  has_one :latest_edition, -> { order(created_at: :desc) }, class_name: "Edition"

  accepts_nested_attributes_for :latest_edition

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end

  def work_in_progress_edition?
    latest_edition.try(:state) == 'draft'
  end
end
