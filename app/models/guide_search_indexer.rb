class GuideSearchIndexer
  def initialize(guide)
    @guide = guide
  end

  def index
    live_edition = guide.live_edition

    if live_edition
      type = "service_manual_guide"
      id = guide.slug

      RUMMAGER_API.add_document(
        type,
        id,
        format:            "service_manual_guide",
        content_store_document_type: "service_manual_guide",
        description:       live_edition.description,
        indexable_content: live_edition.body,
        title:             live_edition.title,
        link:              guide.slug,
        manual:            "/service-manual",
        organisations:     ["government-digital-service"],
      )
    end
  end

  def delete
    RUMMAGER_API.delete_content(guide.slug)
  end

private

  attr_reader :guide
end
