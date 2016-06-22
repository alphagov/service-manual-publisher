require "rails_helper"

RSpec.describe ServiceStandardPresenter, "#content_id" do
  it "is a preassigned UUID" do
    point_scope = double(:point_scope)

    expect(
      described_class.new(point_scope).content_id
    ).to eq("00f693d4-866a-4fe6-a8d6-09cd7db8980b")
  end
end

RSpec.describe ServiceStandardPresenter, "#content_payload" do
  it "returns a hash suitable for a service standard draft" do
    point_scope = double(:point_scope)

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
      title: 'The Digital Service Standard',
    }

    expect(
      described_class.new(point_scope).content_payload
    ).to eq(expected_payload)
  end
end

RSpec.describe ServiceStandardPresenter, "#links_payload" do
  it "includes points" do
    point1 = create(:point)
    point2 = create(:point)

    expected_payload = {
      links: {
        points: [point1.content_id, point2.content_id]
      }
    }

    expect(
      described_class.new([point1, point2]).links_payload
    ).to eq(expected_payload)
  end
end
