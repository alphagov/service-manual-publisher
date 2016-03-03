require 'rails_helper'

RSpec.describe Topic do
  it "allows setting the topic path that starts with '/service-manual/'" do
    topic = build(:topic, path: "/service-manual/hello")
    topic.valid?
    expect(topic.errors[:path].size).to eq 0
  end

  it "doesn't allow changing the path again" do
    topic = build_stubbed(:topic, path: "/service-manual/hello")
    topic.path = "/service-manual/wemklfenlkwecw"
    topic.valid?
    expect(topic.errors[:path].size).to eq 1
  end

  it "doesn't allow paths without /service-manual/ prefix" do
    topic = build(:topic, path: "/something")
    topic.valid?
    expect(topic.errors.full_messages_for(:path)).to eq ["Path must be present and start with '/service-manual/'"]
  end

  it "does not allow unsupported characters in paths" do
    topic = build(:topic, path: "/service-manual/financing$$$.xml}")
    topic.valid?
    expect(topic.errors.full_messages_for(:path)).to eq ["Path can only contain letters, numbers and dashes"]
  end

  describe "on create callbacks" do
    it "generates and sets content_id" do
      topic = build(:topic, content_id: nil)
      topic.valid?
      expect(topic.content_id).to be_present
    end
  end
end
