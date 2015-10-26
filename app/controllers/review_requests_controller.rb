class ReviewRequestsController < ApplicationController
  def create
    review_request = ReviewRequest.create!

    guide = Guide.find(params[:review_request][:guide_id])
    editions = guide.editions.where(review_request: nil)
    editions.each do |edition|
      edition.review_request = review_request
      edition.save!
    end

    redirect_to root_path, notice: "Your review request has been created!"
  end
end
