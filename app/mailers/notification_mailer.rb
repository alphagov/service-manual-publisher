class NotificationMailer < ApplicationMailer
  def comment_added(comment)
    @comment = comment
    @edition = comment.commentable
    mail(
      to: @edition.notification_subscribers.map { |recipient| user_email(recipient) },
      subject: "New comment on \"#{@edition.title}\""
    )
  end

  def approved_for_publishing(edition)
    @edition = edition
    @approval = edition.approval
    mail(
      to: @edition.notification_subscribers.map { |recipient| user_email(recipient) },
      subject: "\"#{@edition.title}\" approved for publishing"
    )
  end

  def published(edition, user)
    @edition = edition
    @user = user
    mail(
      to: @edition.notification_subscribers.map { |recipient| user_email(recipient) },
      subject: "\"#{@edition.title}\" has been published"
    )
  end
end
