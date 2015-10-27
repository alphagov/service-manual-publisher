class ReviewRequestsController < ApplicationController
  def create
    review_request = ReviewRequest.create!

    guide = Guide.find(params[:review_request][:guide_id])
    guide.editions
      .where(review_request: nil)
      .update_all(review_request_id: review_request)

    redirect_to root_path, notice: "Your review request has been created!"
  end
end
