require 'yaml'
require "gds_api/publishing_api_v2"

# The YAML data files are generated using a script
# https://gist.github.com/tadast/defd1b6fc1e2eccd77f3

namespace :hierarchy_spike do
  desc "Store hard-coded Service Manual Section hierarchy to the publishing API as a draft"
  task publish_guides: [:environment] do
    publish_from_file("guides.yml")
  end

  desc "Publish hard-coded Service Manual Section hierarchy that was previously saved as a draft"
  task publish_sections: [:environment] do
    publish_from_file("section_hierarchy.yml")
  end

  def publish_from_file(file_name)
    publishing_api = GdsApi::PublishingApiV2.new(Plek.new.find('publishing-api'))
    with_payload(file_name) do |payload|
      publishing_api.put_content(payload[:content_id], payload)
      publishing_api.publish(payload[:content_id], 'minor')
    end
  end

  def with_payload(file_name)
    payloads = YAML.load_file(Rails.root.join('lib', 'tasks_data', file_name))
    payloads.each do |payload|
      print "Publishing #{payload[:title]} at #{payload[:base_path]}"
      yield(payload)
      puts " ✔️"
    end
  end
end
