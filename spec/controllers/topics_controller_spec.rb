require 'rails_helper'

RSpec.describe TopicsController, type: :controller do
  before do
    login_as build(:user)
  end

  describe '#update' do
    context 'when publishing' do
      it 'publishes the topic to the publishing api' do
        stub_any_publishing_api_publish
        stub_any_rummager_post
        topic = create(:topic)

        put :update, params: {
          id: topic.id,
          publish: true
        }

        assert_publishing_api_publish(topic.content_id)
      end

      it 'sends the topic to rummager' do
        stub_any_publishing_api_publish
        stub_any_rummager_post
        topic = create(:topic, path: '/service-manual/a-topic')

        put :update, params: {
          id: topic.id,
          publish: true
        }

        assert_rummager_posted_item(_id: '/service-manual/a-topic')
      end
    end
  end
end
