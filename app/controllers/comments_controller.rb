class CommentsController < ApplicationController
  def create
    @edition = Edition.find(params[:comment][:edition_id])
    @comment = @edition.comments.build(
      user: current_user,
      comment: params[:comment][:comment],
    )

    if @comment.save
      unless @edition.notification_subscribers == [@comment.user]
        NotificationMailer.comment_added(@comment).deliver_later
      end
      redirect_to "#{edition_comments_path(@edition)}##{@comment.html_id}"
    else
      @guide = @edition.guide
      @editions = @guide.editions.order(created_at: :desc)
      flash[:notice] = "Comment has been created"
      render "editions/comments"
    end
  end
end
