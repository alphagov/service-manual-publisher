require "rails_helper"

RSpec.describe HomepagePresenter, "#content_id" do
  it "returns a preassigned UUID" do
    expect(
      described_class.new.content_id
    ).to eq("6732c01a-39e2-4cec-8ee9-17eb7fded6a0")
  end
end

RSpec.describe HomepagePresenter, "#content_payload" do
  it "conforms to the schema" do
    homepage_presenter = described_class.new

    expect(homepage_presenter.content_payload).to be_valid_against_schema('service_manual_homepage')
  end

  it 'includes a title for the service manual' do
    payload = described_class.new.content_payload

    expect(payload).to include title: "Service Manual"
  end

  it 'includes a description for the service manual' do
    payload = described_class.new.content_payload

    expect(payload).to include \
      description: 'Helping government teams create and run great digital services that meet the Digital Service Standard.'
  end

  it 'includes a base path and exact route for the service manual' do
    payload = described_class.new.content_payload

    expect(payload).to include \
      base_path: '/service-manual',
      routes: [
        { type: 'exact', path: '/service-manual' }
      ]
  end

  it 'includes the rendering and publishing apps' do
    payload = described_class.new.content_payload

    expect(payload).to include \
      publishing_app: 'service-manual-publisher',
      rendering_app: 'service-manual-frontend'
  end

  it 'includes the document and schema type' do
    payload = described_class.new.content_payload

    expect(payload).to include \
      document_type: 'service_manual_homepage',
      schema_name: 'service_manual_homepage'
  end
end
