class EditionsController < ApplicationController
  def comments_and_history
    @edition = Edition.find(params[:id])
    @guide = @edition.guide
    @latest_edition_per_edition_group = @guide.latest_edition_per_edition_group
    @comment = Comment.new
  end
end
