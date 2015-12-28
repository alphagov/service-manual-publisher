require 'rails_helper'

RSpec.describe GuidesController, type: :controller do
  let(:content_designer) { Generators.valid_user(name: "Content Designer", email: "content.designer@example.com") }

  before do
    login_as content_designer
    allow_any_instance_of(GuidePublisher).to receive(:publish)
  end

  describe "#update" do
    it 'notifies about search indexing errors but does not fail the transaction' do
      expect_any_instance_of(Rummageable::Index).to receive(:add_batch).and_raise("Something went wrong")
      edition = Generators.valid_edition(state: 'approved')
      Guide.create!(slug: "/service-manual/test", editions: [edition])
      expect(controller).to receive(:notify_airbrake)

      put :update, id: edition.guide_id, publish: true

      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq "Guide has been published"
    end

    describe "#approve_for_publication" do
      it "sends an email notification" do
        edition = Generators.valid_edition(state: 'review_requested')
        Guide.create!(slug: "/service-manual/test", editions: [edition])
        allow_any_instance_of(Edition).to receive(:notification_subscribers).and_return([content_designer])

        put :update, id: edition.guide_id, approve_for_publication: true

        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(ActionMailer::Base.deliveries.last.to).to eq ["content.designer@example.com"]
        expect(ActionMailer::Base.deliveries.last.subject).to include("approved for publishing")
      end
    end
  end
end
