require 'rails_helper'

RSpec.describe TopicHelper, "#topic_view_url" do
  it "returns correct content url" do
    topic = Topic.new(path: "/service-manual/a-topic")
    expect(view_topic_url(topic)).to eq "http://www.dev.gov.uk/service-manual/a-topic"
  end
end
