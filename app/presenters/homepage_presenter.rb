class HomepagePresenter
  HOMEPAGE_CONTENT_ID = "6732c01a-39e2-4cec-8ee9-17eb7fded6a0".freeze

  def content_id
    HOMEPAGE_CONTENT_ID
  end

  def content_payload
    {
      base_path: "/service-manual",
      title: "Service Manual",
      description: "Helping government teams create and run great digital services that meet the Service Standard.",
      details: {},
      routes: [
        { type: "exact", path: "/service-manual" },
      ],
      document_type: "service_manual_homepage",
      schema_name: "service_manual_homepage",
      publishing_app: "service-manual-publisher",
      rendering_app: "service-manual-frontend",
      locale: "en",
    }
  end
end
