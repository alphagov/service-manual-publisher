class GuideSearchIndexer
  def initialize(guide, rummager_api: RUMMAGER_API)
    @guide = guide
    @rummager_api = rummager_api
  end

  def index
    live_edition = guide.live_edition

    if live_edition
      type = "service_manual_guide"
      id = guide.slug

      rummager_api.add_document(
        type,
        id,
        {
          "format":            "service_manual_guide",
          "description":       live_edition.description,
          "indexable_content": live_edition.body,
          "title":             live_edition.title,
          "link":              guide.slug,
          "manual":            "/service-manual",
          "organisations":     ["government-digital-service"],
        })
    end
  end

  def delete
    rummager_api.delete_content!(guide.slug)
  end

private

  attr_reader :guide, :rummager_api

end
