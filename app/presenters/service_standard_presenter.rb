class ServiceStandardPresenter
  SERVICE_STANDARD_CONTENT_ID = "00f693d4-866a-4fe6-a8d6-09cd7db8980b".freeze

  def content_id
    SERVICE_STANDARD_CONTENT_ID
  end

  def content_payload
    {
      base_path: '/service-manual/service-standard',
      document_type: 'service_manual_service_standard',
      update_type: 'major',
      locale: 'en',
      phase: 'beta',
      publishing_app: 'service-manual-publisher',
      rendering_app: 'service-manual-frontend',
      routes: [
        { type: 'exact', path: '/service-manual/service-standard' }
      ],
      schema_name: 'service_manual_service_standard',
      title: 'Service Standard',
      description: "The Service Standard helps teams to create and run great public services.",
      details: {
        body: '<p>Check whether you need to use <a href="/service-manual/service-assessments/pre-july-2019-digital-service-standard"> the previous version of the Service Standard</a>.</p>'
      }
    }
  end

  def links_payload
    {
      links: {
        email_alert_signup: [
          ServiceStandardEmailAlertSignupPresenter::SERVICE_STANDARD_EMAIL_ALERT_SIGNUP_CONTENT_ID,
        ],
        primary_publishing_organisation: [ServiceManualPublisher::GDS_ORGANISATION_CONTENT_ID]
      }
    }
  end
end
