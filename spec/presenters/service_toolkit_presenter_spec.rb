require "rails_helper"

RSpec.describe ServiceToolkitPresenter, "#content_id" do
  let(:content_id) { described_class.new.content_id }

  it "returns a preassigned UUID" do
    expect(content_id).to eq "7397b402-57cd-4208-9d6b-1f59245f3c75"
  end
end

RSpec.describe ServiceToolkitPresenter, "#content_payload" do
  let(:payload) { described_class.new.content_payload }

  it "returns a payload that validates against the service toolkit schema" do
    expect(payload).to be_valid_against_publisher_schema "service_manual_service_toolkit"
  end

  it "includes in the payload a base path of /service-toolkit" do
    expect(payload[:base_path]).to eq "/service-toolkit"
  end

  it "includes in the payload an exact route for /service-toolkit" do
    expect(payload[:routes]).to eq [
      { type: "exact", path: "/service-toolkit" },
    ]
  end

  it 'includes in the payload the title "Service Toolkit"' do
    expect(payload[:title]).to eq "Service Toolkit"
  end

  it "includes in the payload a suitable description" do
    expect(payload[:description]).to eq(
      "All you need to design, build and run services that meet government standards.",
    )
  end

  it "includes in the payload all other necessary metadata" do
    expect(payload).to include(
      document_type: "service_manual_service_toolkit",
      schema_name: "service_manual_service_toolkit",
      publishing_app: "service-manual-publisher",
      rendering_app: "government-frontend",
      locale: "en",
    )
  end

  it "includes a list of collections" do
    expect(payload[:details]).to have_key(:collections)
  end

  it "includes a title, description and valid list of links for every collection" do
    collections = payload[:details][:collections]

    a_valid_link = {
      title: an_instance_of(String),
      description: an_instance_of(String),
      url: an_instance_of(String),
    }

    a_valid_collection = {
      title: an_instance_of(String),
      description: an_instance_of(String),
      links: (all include a_valid_link),
    }

    expect(collections).to all include a_valid_collection
  end
end
