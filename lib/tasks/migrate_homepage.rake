require 'gds_api/publishing_api'
require 'highline'

desc "Migrate the homepage"
task migrate_homepage: :environment do
  cli = HighLine.new
  cli.say cli.color(
    "Publishing the homepage will make the old service manual inaccessible. Continue?",
    :red
  )
  exit unless cli.agree "Are you sure you wish to continue?"

  publishing_api_v1 = GdsApi::PublishingApi.new(
    Plek.new.find('publishing-api'),
    bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
  )

  # Take ownership of the path reservation
  publishing_api_v1.put_path('/service-manual',
    publishing_app: 'service-manual-publisher',
    override_existing: true
  )

  homepage = HomepagePresenter.new
  
  # Save and publish the homepage
  PUBLISHING_API.put_content(
    homepage.content_id,
    homepage.content_payload
  )

  PUBLISHING_API.publish(
    homepage.content_id,
    "major"
  )

  puts "Done."
end
