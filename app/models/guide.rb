class Guide < ActiveRecord::Base
  validates :content_id, presence: true, uniqueness: true
  validates :slug, presence: true

  has_many :editions
  has_one :latest_edition, -> { order(created_at: :desc) }, class_name: "Edition"

  accepts_nested_attributes_for :latest_edition

  PUBLISHERS = {
    "Design Community" => "https://designpatterns.hackpad.com"
  }

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end

  after_save :write_to_content_store

  def write_to_content_store
    require "gds_api/publishing_api"

    publishing_api = GdsApi::PublishingApi.new(Plek.new.find('publishing-api'))
    rendered_body = Govspeak::Document.new(latest_edition.body)

    data = {
      publishing_app: "service-manual-publisher",
      rendering_app: "government-frontend",
      public_updated_at: latest_edition.created_at,
      routes: [
        { type: "exact", path: slug }
      ],
      format: "service_manual_guide",
      title: latest_edition.title,
      update_type: 'minor',
      details: { body: rendered_body },
    }

    if latest_edition.draft?
      publishing_api.put_draft_content_item(slug, data)
    elsif latest_edition.published?
      publishing_api.put_content_item(slug, data)
    end
  end
end
