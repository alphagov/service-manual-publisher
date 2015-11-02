class ReviewRequestsController < ApplicationController
  def create
    edition = Edition.find(params[:edition_id])
    edition.state = 'review_requested'
    edition.save!
    redirect_to root_path, notice: "A review has been requested"
  end
end
