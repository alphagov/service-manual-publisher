class ApprovalsController < ApplicationController
  def create
    review_request = ReviewRequest.find(params[:approval][:review_request_id])
    review_request.approvals << Approval.new(user: current_user)
    redirect_to root_path, notice: "Thanks for approving this guide"
  end
end
