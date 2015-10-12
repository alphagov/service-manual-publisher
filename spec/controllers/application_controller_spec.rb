require 'rails_helper'

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
  end
end
