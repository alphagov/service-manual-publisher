require 'rails_helper'

RSpec.describe Guide do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      edition = Generators.valid_published_edition(title: "something", state: "published")
      guide = Guide.create!(slug: "/service-manual/slug", content_id: nil, latest_edition: edition)
      expect(guide.content_id).to be_present
    end
  end

  describe "validations" do
    it "doesn't allow slugs without /service-manual/ prefix" do
      edition = Generators.valid_published_edition(title: "something", state: "published")
      edition = Guide.new(slug: "/something", latest_edition: edition)
      edition.valid?
      expect(edition.errors.full_messages_for(:slug)).to eq ["Slug must be be prefixed with /service-manual/"]
    end
  end

end
