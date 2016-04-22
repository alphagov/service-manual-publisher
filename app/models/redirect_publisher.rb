require "gds_api/publishing_api_v2"

class RedirectPublisher
  def process(content_id:, old_path:, new_path:)
    data = {
      format: "redirect",
      base_path: old_path,
      publishing_app: "service-manual-publisher",
      redirects: [
        {
          path: old_path,
          type: "exact",
          destination: new_path,
        }
      ]
    }
    publishing_api = GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
    publishing_api.put_content(content_id, data)
    publishing_api.publish(content_id, "major")
  end
end
