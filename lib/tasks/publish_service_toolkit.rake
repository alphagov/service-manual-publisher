namespace :publish do
  desc "Publish the Service Toolkit"
  task service_toolkit: :environment do
    toolkit = ServiceToolkitPresenter.new

    puts "Creating service toolkit..."
    PUBLISHING_API.put_content(toolkit.content_id, toolkit.content_payload)

    PUBLISHING_API.patch_links(toolkit.content_id, toolkit.links_payload)

    puts "Publishing the service toolkit..."
    PUBLISHING_API.publish(toolkit.content_id, "major")

    puts "Done."
  end
end
