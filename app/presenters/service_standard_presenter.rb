class ServiceStandardPresenter
  SERVICE_STANDARD_CONTENT_ID = "00f693d4-866a-4fe6-a8d6-09cd7db8980b"

  def initialize(points)
    @points = points
  end

  def content_id
    SERVICE_STANDARD_CONTENT_ID
  end

  def content_payload
    {
      base_path: '/service-manual/service-standard',
      document_type: 'service_manual_service_standard',
      phase: 'beta',
      publishing_app: 'service-manual-publisher',
      rendering_app: 'service-manual-frontend',
      routes: [
        { type: 'exact', path: '/service-manual/service-standard' }
      ],
      schema_name: 'service_manual_service_standard',
      title: 'The Digital Service Standard',
    }
  end

  def links_payload
    {
      links: {
        points: points.map(&:content_id)
      }
    }
  end

private

  attr_reader :points
end
