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

  describe "back_or_default" do
    it "returns referer if there's one" do
      request.env['HTTP_REFERER'] = 'referer_url'
      expect(controller.back_or_default('default')).to eq 'referer_url'
    end

    it "returns root_url if there's no referer nor fallback path" do
      request.env['HTTP_REFERER'] = nil
      expect(controller.back_or_default).to eq root_url
    end

    it "returns fallback uri if there's no referer" do
      request.env['HTTP_REFERER'] = nil
      expect(controller.back_or_default('fallback_url')).to eq 'fallback_url'
    end

    it "returns fallback uri if referer is the same as current url to avoid infinite loops" do
      request.env['HTTP_REFERER'] = 'infinite_loop_url'
      allow(request).to receive(:url).and_return('infinite_loop_url')
      expect(controller.back_or_default('fallback_url')).to eq 'fallback_url'
    end
  end
end
