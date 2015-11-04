class DraftsController < ApplicationController
  def create
    guide = Guide.find(params[:guide_id])
    duplicated_edition = guide.latest_edition.dup
    duplicated_edition.state = "draft"
    guide.editions << duplicated_edition
    redirect_to edit_guide_path(guide)
  end
end
