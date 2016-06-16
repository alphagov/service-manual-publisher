class TopicSearchIndexer
  def initialize(topic, rummager_api: RUMMAGER_API)
    @topic = topic
    @rummager_api = rummager_api
  end

  def index
    type = "service_manual_topic"
    id = topic.path

    rummager_api.add_document(
      type,
      id,
      "format":            "service_manual_topic",
      "description":       topic.description,
      "indexable_content": topic.title + "\n\n" + topic.description,
      "title":             topic.title,
      "link":              topic.path,
      "manual":            "/service-manual",
      "organisations":     ["government-digital-service"]
    )
  end

private

  attr_reader :topic, :rummager_api
end
