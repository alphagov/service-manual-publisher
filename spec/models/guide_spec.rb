require 'rails_helper'

RSpec.describe Guide do
  def valid_edition(attributes = {})
    attributes = {
      title:           "The Title",
      state:           "draft",
      phase:           "beta",
      description:     "Description",
      update_type:     "major",
      body:            "# Heading",
      publisher_title: "Publisher Name"
    }.merge(attributes)

    Edition.new(attributes)
  end

  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      allow_any_instance_of(Guide).to receive(:publish)
      edition = valid_edition(title: "something", state: "published")
      guide = Guide.create!(slug: "/slug", content_id: nil, latest_edition: edition)
      expect(guide.content_id).to be_present
    end
  end

  describe "publishing" do
    it "saves published items" do
      guide = Guide.new(latest_edition: valid_edition(state: 'published'), slug: "/test/slug")

      double_api = double(:publishing_api)
      expected_plek = Plek.new.find('publishing-api')
      expect(GdsApi::PublishingApi).to receive(:new).with(expected_plek).and_return(double_api)

      expect(double_api).to receive(:put_content_item).with(guide.slug, an_instance_of(Hash))
      guide.save!
    end

    it "saves draft items" do
      guide = Guide.new(latest_edition: valid_edition, slug: "/test/slug")

      double_api = double(:publishing_api)
      expected_plek = Plek.new.find('publishing-api')
      expect(GdsApi::PublishingApi).to receive(:new).with(expected_plek).and_return(double_api)

      expect(double_api).to receive(:put_draft_content_item).with(guide.slug, an_instance_of(Hash))
      guide.save!
    end
  end
end
