class NotificationMailer < ApplicationMailer
  def comment_added(comment)
    @comment = comment
    @edition = comment.commentable
    mail(
      to: @edition.notification_subscribers.map { |recipient| user_email(recipient) },
      subject: "New comment on \"#{@edition.title}\""
    )
  end
end
