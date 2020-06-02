desc "Unpublish all email signup pages"
task unpublish_email_signup: :environment do
  Topic.find_each do |topic|
    presenter = TopicPresenter.new(topic)
    email_signup_presenter = TopicEmailAlertSignupPresenter.new(topic)

    RedirectPublisher.new.process(
      content_id: topic.email_alert_signup_content_id,
      old_path: email_signup_presenter.content_payload[:base_path],
      new_path: presenter.content_payload[:base_path],
    )
  end

  service_standard_presenter = ServiceStandardPresenter.new
  service_standard_email_presenter = ServiceStandardEmailAlertSignupPresenter.new

  RedirectPublisher.new.process(
    content_id: service_standard_email_presenter.content_id,
    old_path: service_standard_email_presenter.content_payload[:base_path],
    new_path: service_standard_presenter.content_payload[:base_path],
  )
end
