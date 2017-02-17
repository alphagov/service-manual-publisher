class ServiceStandardPresenter
  SERVICE_STANDARD_CONTENT_ID = "00f693d4-866a-4fe6-a8d6-09cd7db8980b".freeze

  def content_id
    SERVICE_STANDARD_CONTENT_ID
  end

  def content_payload
    {
      base_path: '/service-manual/service-standard',
      document_type: 'service_manual_service_standard',
      locale: 'en',
      phase: 'beta',
      publishing_app: 'service-manual-publisher',
      rendering_app: 'service-manual-frontend',
      routes: [
        { type: 'exact', path: '/service-manual/service-standard' }
      ],
      schema_name: 'service_manual_service_standard',
      title: 'Digital Service Standard',
      description: "The Digital Service Standard is a set of 18 criteria to help government create and run good digital services.",
      details: {
        body: "All public facing transactional services must meet the standard. It’s used by departments and the Government Digital Service to check whether a service is good enough for public use.",
        poster_url: "http://example.com"
      }
    }
  end

  def links_payload
    {
      links: {
        email_alert_signup: [
          ServiceStandardEmailAlertSignupPresenter::SERVICE_STANDARD_EMAIL_ALERT_SIGNUP_CONTENT_ID
        ]
      }
    }
  end
end
