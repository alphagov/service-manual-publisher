desc "Save draft and publish the service standard"
task publish_service_standard: :environment do
  service_standard_for_publication =
    ServiceStandardPresenter.new(Point.all)

  PUBLISHING_API.put_content(
    service_standard_for_publication.content_id,
    service_standard_for_publication.content_payload
  )
  PUBLISHING_API.publish(
    service_standard_for_publication.content_id,
    "major"
  )
end
