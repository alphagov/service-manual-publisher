class EditionsController < ApplicationController
  def index
    @guide = Guide.includes(editions: :author).find(params[:guide_id])
    @current_edition = if params[:current_edition].present?
                         @guide.editions.find(params[:current_edition])
                       else
                         @guide.latest_edition
                       end
    @latest_edition_per_edition_group = @guide.latest_edition_per_edition_group
    @comment = Comment.new
  end
end
