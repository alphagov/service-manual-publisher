require "gds_api/publishing_api"

desc "Migrate the homepage and make the old manual inaccessible"
task migrate_homepage: :environment do
  publishing_api_v1 = GdsApi::PublishingApi.new(
    Plek.new.find("publishing-api"),
    bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
  )

  # Take ownership of the path reservation
  puts "Taking ownership of the path..."
  publishing_api_v1.put_path("/service-manual",
    publishing_app: "service-manual-publisher",
    override_existing: true,
  )

  homepage = HomepagePresenter.new

  # Save a draft of the homepage
  puts "Creating homepage..."
  PUBLISHING_API.put_content(
    homepage.content_id,
    homepage.content_payload,
  )

  # Republish all topics (as children of the homepage)
  Topic.find_each do |topic|
    puts "Republishing #{topic.title}..."

    publisher = TopicPublisher.new(topic: topic)
    publisher.save_draft
    publisher.publish
  end

  # Publish the homepage
  puts "Publishing the homepage..."
  PUBLISHING_API.publish(
    homepage.content_id,
    "major",
  )

  puts "Done."
end
