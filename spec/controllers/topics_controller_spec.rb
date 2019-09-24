require "rails_helper"

RSpec.describe TopicsController, type: :controller do
  before do
    login_as build(:user)
  end

  describe "#update" do
    context "when publishing" do
      it "publishes the topic to the publishing api" do
        stub_any_publishing_api_publish
        topic = create(:topic)

        put :update, params: {
          id: topic.id,
          publish: true,
        }

        assert_publishing_api_publish(topic.content_id)
      end
    end
  end
end
