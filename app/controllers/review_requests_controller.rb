class ReviewRequestsController < ApplicationController
  def create
    edition = Edition.find(params[:edition_id])
    edition.state = 'review_requested'
    edition.save!
    redirect_to edition_path(edition), notice: "A review has been requested"
  end
end
