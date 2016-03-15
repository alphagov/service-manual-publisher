require 'rails_helper'

RSpec.describe SearchIndexer do
  it "indexes topics in rummager" do
    index = double(:rummageable_index)
    plek = Plek.current.find('rummager')
    expect(Rummageable::Index).to receive(:new).with(plek, "/mainstream").and_return index
    topic = Topic.create!(
      path: "/service-manual/topic1",
      title: "The Topic Title",
      description: "The Topic Description",
    )
    expect(index).to receive(:add_batch).with([{
      format:            "service_manual_topic",
      _type:             "service_manual_topic",
      description:       topic.description,
      indexable_content: topic.title + "\n\n" + topic.description,
      title:             topic.title,
      link:              topic.path,
      manual:            "service-manual",
      organisations:     ["government-digital-service"]
    }])
    TopicSearchIndexer.new(topic).index
  end
end
