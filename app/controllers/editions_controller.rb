class EditionsController < ApplicationController
  def show
    @edition = Edition.find(params[:id])
    @guide = @edition.guide
  end

  def comments
    @edition = Edition.find(params[:id])
    @guide = @edition.guide
    @editions = @guide.editions.order(created_at: :desc)
  end
end
