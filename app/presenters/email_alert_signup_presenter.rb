class EmailAlertSignupPresenter
  def initialize(topic)
    @topic = topic
  end

  def content_id
    topic.email_alert_signup_content_id
  end

  def content_payload
    {
      base_path: path,
      details: {
        summary: summary,
        subscriber_list: subscriber_list_definition
      },
      schema_name: 'email_alert_signup',
      document_type: 'email_alert_signup',
      locale: 'en',
      publishing_app: 'service-manual-publisher',
      rendering_app: 'email-alert-frontend',
      routes: [
        {
          path: path,
          type: 'exact'
        }
      ],
      title: title,
    }
  end

private

  attr_reader :topic

  def path
    [topic.path.chomp("/"), 'email-signup'].join('/')
  end

  def title
    "Service Manual – #{topic.title}"
  end

  def summary
    "You'll receive an email whenever a guide is created or updated within this topic."
  end

  def subscriber_list_definition
    {
      document_type: 'service_manual_guide',
      links: {
        service_manual_topics: [topic.content_id]
      }
    }
  end
end
