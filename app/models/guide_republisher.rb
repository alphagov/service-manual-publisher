class GuideRepublisher
  def initialize(guides, publishing_api: PUBLISHING_API)
    @guides = guides
    @publishing_api = publishing_api
  end

  def republish
    guides.each do |guide|
      publisher = Publisher.new(content_model: guide, publishing_api: publishing_api)
      publisher.save_draft(GuidePresenter.new(guide, guide.latest_edition))
      publisher.publish
    end
  end

private
  attr_reader :guides, :publishing_api
end
