class GuideTaggerJob < ActiveJob::Base
  queue_as :default

  def self.batch_perform_later(topic)
    topic.guide_content_ids.each do |guide_content_id|
      perform_later(guide_content_id: guide_content_id, topic_content_id: topic.content_id)
    end
  end

  def perform(guide_content_id:, topic_content_id:)
    PUBLISHING_API.patch_links(
      guide_content_id,
      links: { service_manual_topics: [topic_content_id] }
    )
  end
end
