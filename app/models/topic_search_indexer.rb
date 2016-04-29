class TopicSearchIndexer
  def initialize(topic, rummager_index: RUMMAGER_INDEX)
    @topic = topic
    @rummager_index = rummager_index
  end

  def index
    rummager_index.add_batch([{
      "format":            "service_manual_topic",
      "_type":             "service_manual_topic",
      "description":       topic.description,
      "indexable_content": topic.title + "\n\n" + topic.description,
      "title":             topic.title,
      "link":              topic.path,
      "manual":            "service-manual",
      "organisations":     ["government-digital-service"],
    }])
  end

private

  attr_reader :topic, :rummager_index

end
