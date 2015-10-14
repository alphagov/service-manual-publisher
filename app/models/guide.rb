require "gds_api/publishing_api"

class Guide < ActiveRecord::Base
  validates :content_id, presence: true, uniqueness: true
  validates :slug, presence: true
  validates_associated :latest_edition

  has_many :editions
  has_one :latest_edition, -> { order(created_at: :desc) }, class_name: "Edition"

  accepts_nested_attributes_for :latest_edition

  PUBLISHERS = {
    "Design Community" => "http://sm-11.herokuapp.com/designing-services/design-community/",
    "Agile Community" => "http://sm-11.herokuapp.com/agile-delivery/agile-community"
  }

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end

  after_save :publish

private

  def publish
    publishing_api = GdsApi::PublishingApi.new(Plek.new.find('publishing-api'))
    rendered_document = Govspeak::Document.new(latest_edition.body)

    level_two_headers = rendered_document.structured_headers.select{|s| s.level == 2}
    level_two_headers = level_two_headers.map {|l| {title: l.text, href: "\##{l.id}"}}
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
      details: {
        body: rendered_document.to_html,
        header_links: level_two_headers,
      },
    }

    if latest_edition.draft?
      publishing_api.put_draft_content_item(slug, data)
    elsif latest_edition.published?
      publishing_api.put_content_item(slug, data)
    end
  end
end
