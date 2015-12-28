class CommentsController < ApplicationController
  def create
    edition = Edition.find(params[:comment][:edition_id])
    comment = edition.comments.create!(
      user: current_user,
      comment: params[:comment][:comment],
    )

    unless edition.notification_subscribers == [comment.user]
      NotificationMailer.comment_added(comment).deliver_later
    end

    redirect_to back_or_default(edition_path(edition), anchor: comment.html_id), notice: "Comment has been created"
  end
end
