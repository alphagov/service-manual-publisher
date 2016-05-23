require 'rails_helper'

RSpec.describe TopicSearchIndexer do
  it "indexes topics in rummager" do
    rummager_api = double(:rummager_api)
    topic = Topic.create!(
      path: "/service-manual/topic1",
      title: "The Topic Title",
      description: "The Topic Description",
    )

    expect(rummager_api).to receive(:add_document).with(
      "service_manual_topic",
      "/service-manual/topic1",
      {
        format:            "service_manual_topic",
        description:       "The Topic Description",
        indexable_content: "The Topic Title\n\nThe Topic Description",
        title:             "The Topic Title",
        link:              "/service-manual/topic1",
        manual:            "/service-manual",
        organisations:     ["government-digital-service"]
      }
    )


    described_class.new(topic, rummager_api: rummager_api).index
  end
end
