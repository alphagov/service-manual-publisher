class GuideSearchIndexer
  def initialize(guide, rummager_index: RUMMAGER_INDEX)
    @guide = guide
    @rummager_index = rummager_index
  end

  def index
    edition = guide.live_edition

    rummager_index.add_batch([{
      "format":            "service_manual_guide",
      "_type":             "service_manual_guide",
      "description":       edition.description,
      "indexable_content": edition.body,
      "title":             edition.title,
      "link":              guide.slug,
      "manual":            "service-manual",
      "organisations":     ["government-digital-service"],
    }])
  end

  def delete
    rummager_index.delete(guide.slug)
  end

private

  attr_reader :guide, :rummager_index

end
