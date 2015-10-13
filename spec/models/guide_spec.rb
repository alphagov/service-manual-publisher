require 'rails_helper'

describe Guide do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      edition = Edition.new(title:"something", state: "published")
      guide = Guide.create!(slug: "/slug", content_id: nil, editions: [edition])
      expect(guide.content_id).to be_present
    end
  end

  it "saves published items" do
    edition = Edition.new(title:"something", state: "published")
    edition.title = "Test Title"
    edition.body = "# Heading"
    edition.created_at = Time.now

    guide = Guide.new(editions: [edition])
    guide.slug = "/test/slug"
    guide.stub(:latest_edition).and_return edition

    double_api = double(:publishing_api)
    double_document = double(:document)

    expected_plek = Plek.new.find('publishing-api')
    expect(GdsApi::PublishingApi).to receive(:new).with(expected_plek).and_return(double_api)
    expect(Govspeak::Document).to receive(:new).with(edition.body).and_return(double_document)

    expected_hash = {
      :publishing_app    => "service-manual-publisher",
      :rendering_app     => "government-frontend",
      :public_updated_at => edition.created_at,
      :routes            => [{:type=>"exact", :path=>guide.slug}],
      :format            => "service_manual_guide",
      :title             => edition.title,
      :update_type       => "minor",
      :details           => {:body=> double_document }
    }

    expect(double_api).to receive(:put_content_item).with(guide.slug, expected_hash)
    guide.save!
  end

  it "saves draft items" do
    edition = Edition.new(title:"something", state: "draft")
    edition.title = "Test Title"
    edition.body = "# Heading"
    edition.created_at = Time.now

    guide = Guide.new(editions: [edition])
    guide.slug = "/test/slug"
    guide.stub(:latest_edition).and_return edition

    double_api = double(:publishing_api)
    double_document = double(:document)

    expected_plek = Plek.new.find('publishing-api')
    expect(GdsApi::PublishingApi).to receive(:new).with(expected_plek).and_return(double_api)
    expect(Govspeak::Document).to receive(:new).with(edition.body).and_return(double_document)

    expected_hash = {
      :publishing_app    => "service-manual-publisher",
      :rendering_app     => "government-frontend",
      :public_updated_at => edition.created_at,
      :routes            => [{:type=>"exact", :path=>guide.slug}],
      :format            => "service_manual_guide",
      :title             => edition.title,
      :update_type       => "minor",
      :details           => {:body=> double_document }
    }

    expect(double_api).to receive(:put_draft_content_item).with(guide.slug, expected_hash)
    guide.save!
  end
end
