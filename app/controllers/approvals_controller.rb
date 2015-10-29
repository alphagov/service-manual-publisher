class ApprovalsController < ApplicationController
  def create
    edition = Edition.find(params[:approval][:edition_id])
    edition.approvals.build(user: current_user)
    edition.state = "approved"
    edition.save!
    redirect_to root_path, notice: "Thanks for approving this guide"
  end
end
