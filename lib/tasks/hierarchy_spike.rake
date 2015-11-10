require 'yaml'
require "gds_api/publishing_api_v2"

# The YAML data files are generated using a script
# https://gist.github.com/tadast/defd1b6fc1e2eccd77f3

GovukContentSchemaTestHelpers.configure do |config|
  config.schema_type = 'publisher'
  config.project_root = Rails.root
end

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
      validate_against_schema(payload)
      publishing_api.put_content(payload[:content_id], payload)
      publishing_api.put_links(payload[:content_id], payload) if payload[:links].present?
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

  def validate_against_schema(payload)
    validator = GovukContentSchemaTestHelpers::Validator.new(payload[:format], payload.to_json)
    if !validator.valid?
      raise "Payload #{payload[:content_id]} not valid against #{payload[:format]} schema: #{validator.errors}"
    end
  end
end
