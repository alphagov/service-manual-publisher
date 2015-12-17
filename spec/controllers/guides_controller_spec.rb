require 'rails_helper'

RSpec.describe GuidesController, type: :controller do
  before do
    login_as User.create(name: "Content Designer", permissions: ["signin"])
    allow_any_instance_of(GuidePublisher).to receive(:publish)
  end

  describe "#update" do
    it 'notifies about search indexing errors but does not fail the transaction' do
      expect_any_instance_of(Rummageable::Index).to receive(:add_batch).and_raise("Something went wrong")
      edition = Generators.valid_edition(state: 'approved')
      guide = Guide.create!(slug: "/service-manual/test", editions: [edition])
      expect(controller).to receive(:notify_airbrake)

      put :update, id: edition.guide_id, publish: true

      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq "Guide has been published"
    end
  end
end
