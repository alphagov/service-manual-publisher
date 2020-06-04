require "rails_helper"

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

  it "has a unique path" do
    create(:topic, path: "/service-manual/nice-topic")
    topic = build(:topic, path: "/service-manual/nice-topic")
    topic.valid?

    expect(
      topic.errors.full_messages_for(:path),
    ).to include("Path has already been taken")
  end

  describe "on create callbacks" do
    it "generates and sets content_id" do
      topic = build(:topic, content_id: nil)
      topic.valid?
      expect(topic.content_id).to be_present
    end
  end

  describe "#ready_to_publish?" do
    it "is not ready to publish if the topic isn't persisted" do
      topic = build(:topic)
      topic.save!

      expect(topic).to be_ready_to_publish
    end

    it "is ready to publish if the topic is persisted" do
      topic = build(:topic)

      expect(topic).to_not be_ready_to_publish
    end
  end

  describe "#guide_content_ids" do
    it "returns the associated guide content ids" do
      topic = create(:topic, :with_some_guides)
      guide_content_ids = topic.topic_sections.map do |topic_section|
        topic_section.guides.map(&:content_id)
      end
      guide_content_ids = guide_content_ids.flatten

      expect(topic.guide_content_ids).to match_array(guide_content_ids)
      expect(topic.guide_content_ids).to_not be_empty
    end
  end
end
