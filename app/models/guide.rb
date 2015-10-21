require "gds_api/publishing_api"

class Guide < ActiveRecord::Base
  validates :content_id, presence: true, uniqueness: true
  validates :slug, presence: true
  validates_associated :latest_edition

  has_many :editions
  has_one :latest_edition, -> { order(created_at: :desc) }, class_name: "Edition"

  accepts_nested_attributes_for :latest_edition

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end

  def work_in_progress_edition?
    latest_edition.try(:state) == 'draft'
  end

  def update_attributes_from_params(params, state:)
    if work_in_progress_edition?
      self.attributes = params
      self.latest_edition.state = state
    else
      self.attributes = params.except(:latest_edition_attributes)
      edition_attributes = params[:latest_edition_attributes].with_indifferent_access
      self.editions.build(edition_attributes.except(:id, :updated_at, :created_at).merge(state: state))
    end
    save
  end
end
