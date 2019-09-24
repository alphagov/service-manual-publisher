require "rails_helper"

RSpec.describe TopicEmailAlertSignupPresenter, "#content_payload" do
  it "conforms to the schema" do
    presenter = described_class.new(create(:topic))

    expect(presenter.content_payload).to be_valid_against_schema("email_alert_signup")
  end

  it "is published by the service-manual-publisher" do
    presenter = described_class.new(create(:topic))

    expect(presenter.content_payload).to include(
      publishing_app: "service-manual-publisher",
    )
  end

  it "is rendered by the email-alert-frontend" do
    presenter = described_class.new(create(:topic))

    expect(presenter.content_payload).to include(
      rendering_app: "email-alert-frontend",
    )
  end

  it "is in English" do
    presenter = described_class.new(create(:topic))

    expect(presenter.content_payload).to include(locale: "en")
  end

  it "defines a base path based on the base path of the topic" do
    topic = create :topic, path: "/service-manual/agile-delivery"
    presenter = described_class.new(topic)

    expect(presenter.content_payload).to include(
      base_path: "/service-manual/agile-delivery/email-signup",
    )
  end

  it "defines a route based on the base path of the topic" do
    topic = create :topic, path: "/service-manual/agile-delivery"
    presenter = described_class.new(topic)

    expect(presenter.content_payload).to include(
      routes: [
        {
          path: "/service-manual/agile-delivery/email-signup",
          type: "exact",
        }
      ],
    )
  end

  it "includes a sensible title based on the topic" do
    presenter = described_class.new(create(:topic, title: "Agile Delivery"))

    expect(presenter.content_payload).to include(
      title: "Service Manual – Agile Delivery",
    )
  end

  it "includes a sensible summary to display on the signup page" do
    presenter = described_class.new(create(:topic, title: "Agile Delivery"))

    expect(presenter.content_payload[:details]).to include(
      summary: "You'll receive an email whenever a guide is created or updated within this topic.",
    )
  end

  it "includes a subscriber list definition suitable for the topic" do
    topic = create :topic
    presenter = described_class.new(topic)

    expect(presenter.content_payload[:details]).to include(
      subscriber_list: {
        document_type: "service_manual_guide",
        links: {
          service_manual_topics: [topic.content_id],
        },
      },
    )
  end
end

RSpec.describe TopicEmailAlertSignupPresenter, "#content_id" do
  it "uses the email alert signup content id from the topic" do
    topic = create :topic
    presenter = described_class.new(topic)

    expect(presenter.content_id).to eq topic.email_alert_signup_content_id
  end
end
