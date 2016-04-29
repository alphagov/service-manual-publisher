class GuideSearchIndexer
  def initialize(guide, rummager_index: RUMMAGER_INDEX)
    @guide = guide
    @rummager_index = rummager_index
  end

  def index
    live_edition = guide.live_edition

    if live_edition
      rummager_index.add_batch([{
        "format":            "service_manual_guide",
        "_type":             "service_manual_guide",
        "description":       live_edition.description,
        "indexable_content": live_edition.body,
        "title":             live_edition.title,
        "link":              guide.slug,
        "manual":            "service-manual",
        "organisations":     ["government-digital-service"],
      }])
    end
  end

  def delete
    rummager_index.delete(guide.slug)
  end

private

  attr_reader :guide, :rummager_index

end
