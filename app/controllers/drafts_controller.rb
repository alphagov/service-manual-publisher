class DraftsController < ApplicationController
  def create
    guide = Guide.find(params[:guide_id])

    if guide.latest_edition.published? == false
      return redirect_to edit_guide_path(guide)
    end

    duplicated_edition = guide.latest_edition.dup
    duplicated_edition.state = "draft"

    ActiveRecord::Base.transaction do
      guide.editions << duplicated_edition
      GuidePublisher.new(guide: guide).process
      redirect_to edit_guide_path(guide)
    end
  rescue GdsApi::HTTPClientError => e
    flash[:error] = e.error_details["error"]["message"]
    redirect_to root_path
  end
end
