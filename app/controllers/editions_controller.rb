class EditionsController < ApplicationController
  def index
    @guide = Guide.find(params[:guide_id])
    @editions = @guide.editions.includes(:user).order(updated_at: :desc)
  end
end
