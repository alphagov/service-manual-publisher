require "rails_helper"

RSpec.describe ServiceStandardPublisher, "#save_draft" do
  it "saves a draft of the email alert signup for the service standard" do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    described_class.new.save_draft

    assert_publishing_api_put_content(
      "4a94ae54-5a47-40c1-b9aa-ff47dcaace85",
      request_json_includes(
        "base_path" => "/service-manual/service-standard/email-signup",
      ),
    )
  end

  it "saves a draft of the service standard with the publishing api" do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    described_class.new.save_draft

    assert_publishing_api_put_content(
      "00f693d4-866a-4fe6-a8d6-09cd7db8980b",
      request_json_includes(
        "base_path" => "/service-manual/service-standard",
      ),
    )
  end

  it "patches links for the service standard" do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    described_class.new.save_draft

    assert_publishing_api_patch_links(
      "00f693d4-866a-4fe6-a8d6-09cd7db8980b",
      links: {
        email_alert_signup: ["4a94ae54-5a47-40c1-b9aa-ff47dcaace85"],
        primary_publishing_organisation: [ServiceManualPublisher::GDS_ORGANISATION_CONTENT_ID],
      },
    )
  end
end

RSpec.describe ServiceStandardPublisher, "#publish" do
  it "publishes the email alert signup for the service standard" do
    stub_any_publishing_api_publish

    described_class.new.publish

    assert_publishing_api_publish("4a94ae54-5a47-40c1-b9aa-ff47dcaace85")
  end

  it "publishes the service standard" do
    stub_any_publishing_api_publish

    described_class.new.publish

    assert_publishing_api_publish("00f693d4-866a-4fe6-a8d6-09cd7db8980b")
  end
end
