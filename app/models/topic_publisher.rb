require "gds_api/publishing_api_v2"

class TopicPublisher
  def initialize(topic)
    @topic = topic
  end

  def put_draft
    data = TopicPresenter.new(topic).exportable_attributes
    publishing_api.put_content(topic.content_id, data)
  end

  def publish
    publishing_api.publish(topic.content_id, 'minor')
  end

  def put_links
    link_data = TopicPresenter.new(topic).links
    publishing_api.put_links(topic.content_id, link_data)

    GuideTaggerJob.batch_perform_later(
      guide_ids: link_data[:links][:linked_items],
      topic_id: topic.content_id
    )
  end

  def publish_immediately
    put_draft
    put_links
    publish
  end

private

  attr_reader :topic

  def publishing_api
    PUBLISHING_API
  end
end
