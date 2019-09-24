class ServiceStandardPublisher
  def initialize
    @service_standard = ServiceStandardPresenter.new
    @email_alert_signup = ServiceStandardEmailAlertSignupPresenter.new
  end

  def save_draft
    save_email_alert_signup_draft
    save_service_standard_draft
  end

  def publish
    publish_email_alert_signup
    publish_service_standard
  end

private

  attr_reader :service_standard, :email_alert_signup

  def save_email_alert_signup_draft
    PUBLISHING_API.put_content(
      email_alert_signup.content_id,
      email_alert_signup.content_payload,
    )
  end

  def save_service_standard_draft
    PUBLISHING_API.put_content(
      service_standard.content_id,
      service_standard.content_payload,
    )

    PUBLISHING_API.patch_links(
      service_standard.content_id,
      service_standard.links_payload,
    )
  end

  def publish_email_alert_signup
    PUBLISHING_API.publish(email_alert_signup.content_id)
  end

  def publish_service_standard
    PUBLISHING_API.publish(service_standard.content_id)
  end
end
