class ApprovalsController < ApplicationController
  def create
    edition = Edition.find(params[:approval][:edition_id])
    edition.approvals << Approval.new(user: current_user)
    redirect_to root_path, notice: "Thanks for approving this guide"
  end
end
