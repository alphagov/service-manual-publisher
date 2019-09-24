require "rails_helper"

RSpec.describe UploadsController, type: :controller do
  before { login_as build(:user) }

  describe "#create" do
    context "when uploading via javascript" do
      it "rejects non-image files" do
        test_pdf = fixture_file_upload("fake.file", "application/pdf")

        post :create, params: {
          format: :js,
          file: test_pdf,
        }

        expect(response.status).to eq 422
        expect(response.body).to include "does not seem to be an image"
      end

      it "accepts image files and response with their URL" do
        test_png = fixture_file_upload("fake.file", "image/png")

        expect(ASSET_API).to receive(:create_asset)
          .and_return("file_url" => "http://uploaded.file/1.png")

        post :create, params: {
          format: :js,
          file: test_png,
        }

        expect(response.status).to eq 201
        expect(response.body).to eq "http://uploaded.file/1.png"
      end
    end

    context "when uploading via form upload" do
      it "accepts any file and responds with its URL" do
        test_pdf = fixture_file_upload("fake.file", "application/pdf")

        expect(ASSET_API).to receive(:create_asset)
          .and_return(file_url: "http://uploaded.file/1.png")

        post :create, params: { file: test_pdf }

        expect(response).to redirect_to(new_upload_path)
      end
    end
  end
end
