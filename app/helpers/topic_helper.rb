module TopicHelper
  def view_topic_url(topic)
    [Plek.new.website_root, topic.path].join('')
  end
end
