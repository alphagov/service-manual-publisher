require "gds_api/publishing_api_v2"

class SlugMigrationPublisher
  def process(slug_migration)
    data = {
      content_id: slug_migration.content_id,
      format: "redirect",
      publishing_app: "service-manual-publisher",
      update_type: "minor",
      redirects: [
        {
          path: slug_migration.slug,
          type: "exact",
          destination: slug_migration.guide.slug,
        }
      ]
    }
    publishing_api = GdsApi::PublishingApiV2.new(Plek.new.find('publishing-api'))
    publishing_api.put_content(slug_migration.content_id, data)
    publishing_api.publish(slug_migration.content_id, "minor")
  end
end
