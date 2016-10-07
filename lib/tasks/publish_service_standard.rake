desc "Save draft and publish the service standard"
task publish_service_standard: :environment do
  puts "Publishing service standard..."

  service_standard_for_publication = ServiceStandardPresenter.new
  email_alert_signup_for_publication = ServiceStandardEmailAlertSignupPresenter.new

  # Save and publish the email alert signup
  PUBLISHING_API.put_content(
    email_alert_signup_for_publication.content_id,
    email_alert_signup_for_publication.content_payload
  )
  PUBLISHING_API.publish(email_alert_signup_for_publication.content_id, "major")

  # Save and publish the service standard
  PUBLISHING_API.put_content(
    service_standard_for_publication.content_id,
    service_standard_for_publication.content_payload
  )
  PUBLISHING_API.patch_links(
    service_standard_for_publication.content_id,
    service_standard_for_publication.links_payload
  )
  PUBLISHING_API.publish(
    service_standard_for_publication.content_id,
    "major"
  )
end
