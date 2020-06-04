class RedirectPublisher
  def initialize(publishing_api = PUBLISHING_API)
    @publishing_api = publishing_api
  end

  def process(content_id:, old_path:, new_path:)
    data = {
      schema_name: "redirect",
      document_type: "redirect",
      base_path: old_path,
      update_type: "major",
      publishing_app: "service-manual-publisher",
      redirects: [
        {
          path: old_path,
          type: "exact",
          destination: new_path,
        },
      ],
    }
    @publishing_api.put_content(content_id, data)
    @publishing_api.publish(content_id)
  end
end
