require 'rails_helper'

RSpec.describe TopicsController, type: :controller do
  let(:content_designer) { build(:user, name: "Content Designer", email: "content.designer@example.com") }

  before do
    content_designer.save!
    login_as content_designer
  end

  describe "#create" do
    it "publishes the topic immediatelly" do
      expect_any_instance_of(TopicPublisher).to receive(:publish_immediately)

      post :create, topic: build(:topic).attributes.merge(tree: [].to_json)
    end

    it "does not persist the topic if publishing fails" do
      expect_any_instance_of(TopicPublisher).to receive(:publish_immediately).and_raise(GdsApi::HTTPErrorResponse.new(422, "Oops", {}))

      post :create, topic: build(:topic).attributes.merge(tree: [].to_json)

      expect(Topic.count).to eq 0
    end
  end

  describe "#update" do
    it "publishes the topic immediatelly" do
      topic = create(:topic)
      expect_any_instance_of(TopicPublisher).to receive(:publish_immediately)

      post :update, id: topic.id, topic: topic.attributes.merge(tree: [].to_json)
    end

    it "does not save the changes if publishing fails" do
      topic = create(:topic, title: "Old")
      expect_any_instance_of(TopicPublisher).to receive(:publish_immediately).and_raise(GdsApi::HTTPErrorResponse.new(422, "Oops", {}))

      post :update, id: topic.id, topic: topic.attributes.merge(title: "New", tree: [].to_json)

      expect(topic.reload.title).to eq "Old"
    end
  end
end
