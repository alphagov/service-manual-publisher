class GuideRepublisher
  def initialize(guides, publishing_api: PUBLISHING_API, logger: Rails.logger)
    @guides = guides
    @publishing_api = publishing_api
    @logger = logger
  end

  def republish
    guides.each do |guide|
      log("Republishing: #{guide.title}")

      publisher = Publisher.new(content_model: guide, publishing_api: publishing_api)
      publisher.save_draft(GuidePresenter.new(guide, guide.latest_edition))
      publisher.publish
    end
  end

private
  attr_reader :guides, :publishing_api

  def log(str)
    @logger << str + "\n"
  end
end
