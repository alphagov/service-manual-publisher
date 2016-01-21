class GuideTaggerJob < ActiveJob::Base
  queue_as :default

  def self.batch_perform_later(guide_ids:, topic_id:, publishing_api:)
    guide_ids.each do |guide_id|
      perform_later(guide_id: guide_id, topic_id: topic_id, publishing_api: publishing_api)
    end
  end

  def perform(guide_id:, topic_id:, publishing_api:)
    publishing_api.put_links(guide_id, links: { topics: [topic_id] })
  end
end
