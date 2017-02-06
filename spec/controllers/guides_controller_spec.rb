require 'rails_helper'

RSpec.describe GuidesController, type: :controller do
  let(:content_designer) { build(:user, name: "Content Designer", email: "content.designer@example.com") }

  before do
    content_designer.save!
    login_as content_designer
    publishing_api = double(:publishing_api)
    allow(publishing_api).to receive(:publish)
    stub_const('PUBLISHING_API', publishing_api)
    allow_any_instance_of(Guide).to receive(:topic).and_return build(:topic)
  end

  describe "#update" do
    describe "#approve_for_publication" do
      it "sends an email notification" do
        edition = build(:edition, state: 'review_requested')
        create(:guide, slug: "/service-manual/topic-name/test", editions: [edition])
        allow_any_instance_of(Edition).to receive(:notification_subscribers).and_return([content_designer])

        put :update, params: {
          id: edition.guide_id,
          approve_for_publication: true,
          guide: { fingerprint_when_started_editing: edition.id.to_s }
        }

        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(ActionMailer::Base.deliveries.last.to).to eq ["content.designer@example.com"]
        expect(ActionMailer::Base.deliveries.last.subject).to include("ready for publishing")
      end
    end

    describe "#publish" do
      it "sends an email notification when published by another user" do
        allow_any_instance_of(GdsApi::Rummager).to receive(:add_document)
        edition = build(:edition, state: 'published')
        create(:guide, slug: "/service-manual/topic-name/test", editions: [edition])
        publisher = build(:user, email: "ms.publisher@example.com")
        allow_any_instance_of(Edition).to receive(:notification_subscribers).and_return([publisher])

        put :update, params: {
          id: edition.guide_id,
          publish: true,
          guide: { fingerprint_when_started_editing: edition.id.to_s }
        }

        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(ActionMailer::Base.deliveries.last.to).to eq ["ms.publisher@example.com"]
        expect(ActionMailer::Base.deliveries.last.subject).to include("has been published")
      end

      it "avoids email notification when published by the author" do
        allow_any_instance_of(GdsApi::Rummager).to receive(:add_document)
        edition = build(:edition, state: 'published')
        create(:guide, slug: "/service-manual/topic-name/test", editions: [edition])
        allow_any_instance_of(Edition).to receive(:notification_subscribers).and_return([content_designer])

        put :update, params: {
          id: edition.guide_id,
          publish: true
        }

        expect(ActionMailer::Base.deliveries.size).to eq 0
      end
    end
  end

  describe "a malicious user trying to initialise an unwanted Guide STI constant" do
    it "defaults to a Guide" do
      get :new, params: {
        type: 'Module'
      }

      expect(assigns[:guide_form].guide.class).to eq(Guide)
    end
  end
end
