desc "Save draft and publish the service standard"
task publish_service_standard: :environment do
  puts "Publishing service standard..."

  service_standard_publisher = ServiceStandardPublisher.new

  service_standard_publisher.save_draft
  service_standard_publisher.publish

  puts "Done."
end
