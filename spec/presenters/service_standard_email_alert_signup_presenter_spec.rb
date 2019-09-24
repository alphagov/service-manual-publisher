require "rails_helper"

RSpec.describe ServiceStandardEmailAlertSignupPresenter, "#content_payload" do
  it "conforms to the schema" do
    presenter = described_class.new

    expect(presenter.content_payload).to be_valid_against_schema("email_alert_signup")
  end

  it "is published by the service-manual-publisher" do
    presenter = described_class.new

    expect(presenter.content_payload).to include(
      publishing_app: "service-manual-publisher",
    )
  end

  it "is rendered by the email-alert-frontend" do
    presenter = described_class.new

    expect(presenter.content_payload).to include(
      rendering_app: "email-alert-frontend",
    )
  end

  it "is in English" do
    presenter = described_class.new

    expect(presenter.content_payload).to include(locale: "en")
  end

  it "defines a base path suffixing the service standard path" do
    presenter = described_class.new

    expect(presenter.content_payload).to include(
      base_path: "/service-manual/service-standard/email-signup",
    )
  end

  it "defines a route that suffixes the service standard path" do
    presenter = described_class.new

    expect(presenter.content_payload).to include(
      routes: [
        {
          path: "/service-manual/service-standard/email-signup",
          type: "exact",
        },
      ],
    )
  end

  it "includes a sensible title referencing the service standard" do
    presenter = described_class.new

    expect(presenter.content_payload).to include(
      title: "Service Manual – Service Standard",
    )
  end

  it "includes a sensible summary to display on the signup page" do
    presenter = described_class.new

    expect(presenter.content_payload[:details]).to include(
      summary: "You'll receive an email whenever the Service Standard is updated.",
    )
  end

  it "includes a subscriber list definition for points – child guides of the service standard" do
    presenter = described_class.new

    expect(presenter.content_payload[:details]).to include(
      subscriber_list: {
        document_type: "service_manual_guide",
        links: {
          parent: [ServiceStandardPresenter::SERVICE_STANDARD_CONTENT_ID],
        },
      },
    )
  end
end

RSpec.describe ServiceStandardEmailAlertSignupPresenter, "#content_id" do
  it "returns a preassigned UUID" do
    presenter = described_class.new

    expect(presenter.content_id).to eq "4a94ae54-5a47-40c1-b9aa-ff47dcaace85"
  end
end
