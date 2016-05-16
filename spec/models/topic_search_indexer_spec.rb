require 'rails_helper'

RSpec.describe TopicSearchIndexer do
  it "indexes topics in rummager" do
    rummager_index = double(:rummager_index)
    topic = Topic.create!(
      path: "/service-manual/topic1",
      title: "The Topic Title",
      description: "The Topic Description",
    )

    expect(rummager_index).to receive(:add_batch).with([{
      format:            "service_manual_topic",
      _type:             "service_manual_topic",
      description:       topic.description,
      indexable_content: topic.title + "\n\n" + topic.description,
      title:             topic.title,
      link:              topic.path,
      manual:            "/service-manual",
      organisations:     ["government-digital-service"]
    }])

    described_class.new(topic, rummager_index: rummager_index).index
  end
end
