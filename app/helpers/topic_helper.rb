module TopicHelper
  def view_topic_url(topic)
    [Plek.find('www'), topic.path].join('')
  end
end
