class TopicSearchIndexer
  def initialize(topic)
    @topic = topic
  end

  def index
    type = "service_manual_topic"
    id = topic.path

    RUMMAGER_API.add_document(
      type,
      id,
      format:            "service_manual_topic",
      content_store_document_type: "service_manual_topic",
      description:       topic.description,
      indexable_content: topic.title + "\n\n" + topic.description,
      title:             topic.title,
      link:              topic.path,
      manual:            "/service-manual",
      organisations:     ["government-digital-service"]
    )
  end

private

  attr_reader :topic
end
