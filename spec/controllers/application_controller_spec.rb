require "rails_helper"

RSpec.describe ApplicationController do
  controller do
    def index
      head :ok
    end
  end

  describe "authentication" do
    it "should authenticate users before every request served by a controller that inherits from ApplicationController" do
      expect(controller).to receive(:authenticate_user!).and_return(true)
      get :index
    end

    it "should set the authenticated user uid as a GdsApi::GovukHeader" do
      user = double(:user, uid: "12345-67890", remotely_signed_out?: false, has_permission?: true)
      login_as(user)

      get :index
      expect(GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user]).to eq("12345-67890")
    end
  end
end
