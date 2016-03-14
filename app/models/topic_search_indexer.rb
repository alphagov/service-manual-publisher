class TopicSearchIndexer
  def initialize(topic)
    @topic = topic
  end

  def index
    rummager_index.add_batch([{
      "format":            "service_manual",
      "_type":             "service_manual",
      "description":       @topic.description,
      "indexable_content": @topic.title + "\n\n" + @topic.description,
      "title":             @topic.title,
      "link":              @topic.path,
      "organisations":     ["government-digital-service"],
    }])
  end

  private

    def rummager_index
      Rummageable::Index.new(
        Plek.current.find('rummager'), '/mainstream'
      )
    end
end
