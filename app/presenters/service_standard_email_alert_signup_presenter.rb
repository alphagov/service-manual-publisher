class ServiceStandardEmailAlertSignupPresenter
  SERVICE_STANDARD_EMAIL_ALERT_SIGNUP_CONTENT_ID = "4a94ae54-5a47-40c1-b9aa-ff47dcaace85".freeze

  def content_id
    SERVICE_STANDARD_EMAIL_ALERT_SIGNUP_CONTENT_ID
  end

  def content_payload
    {
      base_path: '/service-manual/service-standard/email-signup',
      update_type: 'major',
      details: {
        summary: "You'll receive an email whenever the Government Service Standard is updated.",
        subscriber_list: {
          document_type: 'service_manual_guide',
          links: {
            parent: [ServiceStandardPresenter::SERVICE_STANDARD_CONTENT_ID]
          }
        }
      },
      schema_name: 'email_alert_signup',
      document_type: 'email_alert_signup',
      locale: 'en',
      publishing_app: 'service-manual-publisher',
      rendering_app: 'email-alert-frontend',
      routes: [
        {
          path: '/service-manual/service-standard/email-signup',
          type: 'exact'
        }
      ],
      title: "Service Manual – Service Standard",
    }
  end
end
