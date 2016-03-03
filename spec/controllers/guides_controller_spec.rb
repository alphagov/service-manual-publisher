require 'rails_helper'

RSpec.describe GuidesController, type: :controller do
  let(:content_designer) { build(:user, name: "Content Designer", email: "content.designer@example.com") }

  before do
    content_designer.save!
    login_as content_designer
    publishing_api = double(:publishing_api)
    allow(publishing_api).to receive(:publish)
    stub_const('PUBLISHING_API', publishing_api)
    ActionMailer::Base.deliveries.clear
    allow_any_instance_of(Guide).to receive(:topic).and_return build(:topic)
    allow_any_instance_of(TopicPublisher).to receive(:publish_immediately)
  end

  describe "#update" do
    describe "#approve_for_publication" do
      it "sends an email notification" do
        edition = build(:edition, state: 'review_requested')
        create(:guide, slug: "/service-manual/test", editions: [edition])
        allow_any_instance_of(Edition).to receive(:notification_subscribers).and_return([content_designer])

        put :update, id: edition.guide_id, approve_for_publication: true

        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(ActionMailer::Base.deliveries.last.to).to eq ["content.designer@example.com"]
        expect(ActionMailer::Base.deliveries.last.subject).to include("approved for publishing")
      end
    end

    describe "#publish" do
      it 'notifies about search indexing errors but does not fail the transaction' do
        expect_any_instance_of(Rummageable::Index).to receive(:add_batch).and_raise("Something went wrong")
        edition = build(:edition, state: 'approved')
        Guide.create!(slug: "/service-manual/test", editions: [edition])
        expect(controller).to receive(:notify_airbrake)

        put :update, id: edition.guide_id, publish: true

        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq "Guide has been published"
      end

      it "sends an email notification when published by another user" do
        allow_any_instance_of(Rummageable::Index).to receive(:add_batch)
        edition = build(:edition, state: 'published')
        Guide.create!(slug: "/service-manual/test", editions: [edition])
        publisher = build(:user, email: "ms.publisher@example.com")
        allow_any_instance_of(Edition).to receive(:notification_subscribers).and_return([publisher])

        put :update, id: edition.guide_id, publish: true

        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(ActionMailer::Base.deliveries.last.to).to eq ["ms.publisher@example.com"]
        expect(ActionMailer::Base.deliveries.last.subject).to include("has been published")
      end

      it "avoids email notification when published by the author" do
        allow_any_instance_of(Rummageable::Index).to receive(:add_batch)
        edition = build(:edition, state: 'published')
        Guide.create!(slug: "/service-manual/test", editions: [edition])
        allow_any_instance_of(Edition).to receive(:notification_subscribers).and_return([content_designer])

        put :update, id: edition.guide_id, publish: true

        expect(ActionMailer::Base.deliveries.size).to eq 0
      end
    end
  end
end
