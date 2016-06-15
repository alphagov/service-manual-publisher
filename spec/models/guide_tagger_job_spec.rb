require 'rails_helper'

RSpec.describe GuideTaggerJob do
  let(:api_double) { double(:publishing_api) }

  before do
    stub_const("PUBLISHING_API", api_double)
  end

  describe "#batch_perform_later" do
    it "adds the topic to all guides" do
      topic = create(:topic, :with_some_guides)
      guide_content_ids = topic.guide_content_ids

      guide_content_ids.each do |guide_content_id|
        expect(api_double).to receive(:patch_links)
          .with(
            guide_content_id,
            links: { service_manual_topics: [topic.content_id], topics: [] },
          )
      end

      GuideTaggerJob.batch_perform_later(topic)
    end
  end
end
