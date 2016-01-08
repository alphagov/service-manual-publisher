class UploadsController < ApplicationController
  def create
    respond_to do |format|
      format.js do
        file = params[:file]
        unless file.content_type.start_with?("image")
          return render text: "The file '#{file.original_filename}' that you're trying to upload does not seem to be an image", status: :unprocessable_entity
        end

        begin
          response = ASSET_API.create_asset(file: file)
          render text: response.file_url, status: 201
        rescue GdsApi::BaseError => e
          render text: e.message, status: :unprocessable_entity
        end
      end
    end
  end
end
