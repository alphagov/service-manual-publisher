class EditionsController < ApplicationController
  def index
    @guide = Guide.find(params[:guide_id])
    @editions = @guide.editions.includes(:user).order(updated_at: :desc)
  end

  def show
    @edition = Edition.find(params[:id])
    @guide = @edition.guide
  end

  def comments
    @edition = Edition.find(params[:id])
    @guide = @edition.guide
    @comments = @edition.comments.for_rendering
  end
end
