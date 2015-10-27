require "gds_api/publishing_api_v2"

class GuidePublisher
  def initialize(guide:, edition:)
    @guide = guide
    @edition = edition
  end

  def process
    publishing_api = GdsApi::PublishingApiV2.new(Plek.new.find('publishing-api'))

    data = GuidePresenter.new(@guide, @edition).exportable_attributes
    publishing_api.put_content(@guide.content_id, data)

    if @edition.published?
      publishing_api.publish(@guide.content_id, @edition.update_type)
    end
  end
end
