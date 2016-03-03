require 'rails_helper'

RSpec.describe UploadsController, type: :controller do
  before { login_as build(:user) }

  describe "#create" do
    it "rejects non-image files" do
      test_pdf = ActionDispatch::Http::UploadedFile.new(
        filename: 'some.pdf',
        type: 'application/pdf',
        tempfile: Object.new
      )
      post :create, format: :js, file: test_pdf

      expect(response.status).to eq 422
      expect(response.body).to include "does not seem to be an image"
    end

    it "accepts image files and response with their URL" do
      test_png = ActionDispatch::Http::UploadedFile.new(
        filename: 'some.pdf',
        type: 'image/png',
        tempfile: Object.new
      )
      expect(ASSET_API).to receive(:create_asset).and_return(OpenStruct.new(file_url: 'http://uploaded.file/1.png'))

      post :create, format: :js, file: test_png

      expect(response.status).to eq 201
      expect(response.body).to eq 'http://uploaded.file/1.png'
    end
  end
end
