class EditionsController < ApplicationController
  def comments
    @edition = Edition.find(params[:id])
    @guide = @edition.guide
    @editions = @guide.editions.order(created_at: :desc)
  end
end
