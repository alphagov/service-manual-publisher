class GuidePublisher
  def initialize(guide:, edition:)
    @guide = guide
    @edition = edition
  end

  def publish!
    data = GuidePresenter.new(@guide, @edition).exportable_attributes

    publishing_api = GdsApi::PublishingApi.new(Plek.new.find('publishing-api'))
    if @edition.draft?
      publishing_api.put_draft_content_item(@guide.slug, data)
    elsif @edition.published?
      publishing_api.put_content_item(@guide.slug, data)
    end
  end
end
