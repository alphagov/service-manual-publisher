class NotificationMailer < ApplicationMailer
  helper GuideRouteHelper

  def comment_added(comment)
    @comment = comment
    @edition = comment.commentable
    view_mail(
      template_id,
      to: @edition.notification_subscribers.map { |recipient| user_email(recipient) },
      subject: "New comment on \"#{@edition.title}\"",
    )
  end

  def ready_for_publishing(guide)
    @guide = guide
    @edition = @guide.latest_edition
    @approval = @edition.approval
    view_mail(
      template_id,
      to: @edition.notification_subscribers.map { |recipient| user_email(recipient) },
      subject: "\"#{@edition.title}\" ready for publishing",
    )
  end

  def published(guide, user)
    @guide = guide
    @edition = @guide.latest_edition
    @user = user
    view_mail(
      template_id,
      to: @edition.notification_subscribers.map { |recipient| user_email(recipient) },
      subject: "\"#{@edition.title}\" has been published",
    )
  end
end
