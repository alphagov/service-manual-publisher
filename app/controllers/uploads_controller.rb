class UploadsController < ApplicationController
  def create
    respond_to do |format|
      format.js do
        file = params[:file]
        unless file.content_type.start_with?("image")
          render body: "The file that you're trying to upload does not seem "\
            "to be an image", status: :unprocessable_entity
          return
        end

        begin
          response = ASSET_API.create_asset(file: file)
          render body: response[:file_url], status: 201
        rescue GdsApi::BaseError => e
          render body: e.message, status: :unprocessable_entity
        end
      end

      format.html do
        file = params[:file]

        begin
          response = ASSET_API.create_asset(file: file)
          redirect_to new_upload_path, notice: "Uploaded successfully to #{response[:file_url]}"
        rescue GdsApi::BaseError => e
          render body: e.message, status: :unprocessable_entity
        end
      end
    end
  end
end
