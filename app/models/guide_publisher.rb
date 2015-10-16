class GuidePublisher
  def initialize guide
    @guide = guide
  end

  def publish!
    data = GuidePresenter.new(@guide, @guide.latest_edition).exportable_attributes

    publishing_api = GdsApi::PublishingApi.new(Plek.new.find('publishing-api'))
    if @guide.latest_edition.draft?
      publishing_api.put_draft_content_item(@guide.slug, data)
    elsif @guide.latest_edition.published?
      publishing_api.put_content_item(@guide.slug, data)
    end
  end
end
