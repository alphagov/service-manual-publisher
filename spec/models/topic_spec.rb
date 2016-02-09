require 'rails_helper'

RSpec.describe Topic do
  it "allows setting the topic path that starts with '/service-manual/'" do
    topic = Generators.valid_topic(path: "/service-manual/hello")
    topic.valid?
    expect(topic.errors[:path].size).to eq 0
  end

  it "doesn't allow changing the path again" do
    topic = Generators.valid_topic(path: "/service-manual/hello")
    topic.save!
    topic.path = "/service-manual/wemklfenlkwecw"
    topic.valid?
    expect(topic.errors[:path].size).to eq 1
  end

  it "doesn't allow paths without /service-manual/ prefix" do
    topic = Topic.new(path: "/something")
    topic.valid?
    expect(topic.errors.full_messages_for(:path)).to eq ["Path must be present and start with '/service-manual/'"]
  end

  it "does not allow unsupported characters in paths" do
    topic = Topic.new(path: "/service-manual/financing$$$.xml}")
    topic.valid?
    expect(topic.errors.full_messages_for(:path)).to eq ["Path can only contain letters, numbers and dashes"]
  end

  describe "on create callbacks" do
    it "generates and sets content_id" do
      topic = Generators.valid_topic(content_id: nil)
      topic.save!
      expect(topic.content_id).to be_present
    end
  end
end
