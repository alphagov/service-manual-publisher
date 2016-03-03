class GuideTaggerJob < ActiveJob::Base
  queue_as :default

  def self.batch_perform_later(guide_ids:, topic_id:)
    guide_ids.each do |guide_id|
      perform_later(guide_id: guide_id, topic_id: topic_id)
    end
  end

  def perform(guide_id:, topic_id:)
    publishing_api.patch_links(guide_id, links: { topics: [topic_id] })
  end

private

  def publishing_api
    PUBLISHING_API
  end
end
