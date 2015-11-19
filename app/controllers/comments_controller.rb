class CommentsController < ApplicationController
  def create
    edition = Edition.find(params[:comment][:edition_id])
    edition.comments.create!(
      user: current_user,
      comment: params[:comment][:comment],
    )

    redirect_to back_or_default(edition_path(edition)), notice: "Comment has been created"
  end
end
