require 'rails_helper'

RSpec.describe TopicSearchIndexer do
  it "indexes topics in rummager" do
    stub_any_rummager_post

    topic = Topic.create!(
      path: "/service-manual/topic1",
      title: "The Topic Title",
      description: "The Topic Description",
    )

    described_class.new(topic).index

    assert_rummager_posted_item(
      _type:              "service_manual_topic",
      _id:                "/service-manual/topic1",
      format:             "service_manual_topic",
      content_store_document_type: "service_manual_topic",
      description:        "The Topic Description",
      indexable_content:  "The Topic Title\n\nThe Topic Description",
      title:              "The Topic Title",
      link:               "/service-manual/topic1",
      manual:             "/service-manual",
      organisations:      ["government-digital-service"],
    )
  end
end
