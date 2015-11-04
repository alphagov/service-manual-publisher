require "gds_api/publishing_api_v2"

class GuidePublisher
  def initialize(guide:)
    @guide = guide
  end

  def process
    publishing_api = GdsApi::PublishingApiV2.new(Plek.new.find('publishing-api'))

    latest_edition = @guide.latest_edition

    data = GuidePresenter.new(@guide, latest_edition).exportable_attributes
    publishing_api.put_content(@guide.content_id, data)

    if latest_edition.published?
      publishing_api.publish(@guide.content_id, latest_edition.update_type)
    end
  end
end
