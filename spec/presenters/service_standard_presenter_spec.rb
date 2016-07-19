require "rails_helper"

RSpec.describe ServiceStandardPresenter, "#content_id" do
  it "returns a preassigned UUID" do
    expect(
      described_class.new.content_id
    ).to eq("00f693d4-866a-4fe6-a8d6-09cd7db8980b")
  end
end

RSpec.describe ServiceStandardPresenter, "#content_payload" do
  it "returns a hash suitable for a service standard draft" do
    expected_payload = {
      base_path: '/service-manual/service-standard',
      document_type: 'service_manual_service_standard',
      phase: 'beta',
      publishing_app: 'service-manual-publisher',
      rendering_app: 'service-manual-frontend',
      routes: [
        { type: 'exact', path: '/service-manual/service-standard' }
      ],
      schema_name: 'service_manual_service_standard',
      title: 'Digital Service Standard',
      details: {
        introduction: "The Digital Service Standard is a set of 18 criteria to help government create and run good digital services.",
        body: "All public facing transactional services must meet the standard. It’s used by departments and the Government Digital Service to check whether a service is good enough for public use.",
      }
    }

    expect(
      described_class.new.content_payload
    ).to eq(expected_payload)
  end
end
