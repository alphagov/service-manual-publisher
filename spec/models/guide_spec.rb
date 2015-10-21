require 'rails_helper'

RSpec.describe Guide do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      edition = Generators.valid_edition(title: "something", state: "published")
      guide = Guide.create!(slug: "/service-manual/slug", content_id: nil, latest_edition: edition)
      expect(guide.content_id).to be_present
    end
  end

  describe "#update_attributes_from_params" do
    it "updates latest_edition if it's currently draft" do
      edition = Generators.valid_edition(title: "something", state: "draft")
      guide = Guide.create!(slug: "/service-manual/slug", latest_edition: edition)

      guide.update_attributes_from_params({ latest_edition_attributes: edition.attributes.merge(title: "New title") }, state: 'draft')

      expect(guide.editions.count).to eq 1
      expect(guide.editions.last.title).to eq "New title"
    end

    it "creates a new edition if the current latest_edition is published" do
      edition = Generators.valid_edition(title: "something", state: "published")
      guide = Guide.create!(slug: "/service-manual/slug", latest_edition: edition)

      guide.update_attributes_from_params({ latest_edition_attributes: edition.attributes.merge(title: "New title") }, state: 'draft')

      expect(guide.editions.count).to eq 2
    end
  end

  describe "validations" do
    it "doesn't allow slugs without /service-manual/ prefix" do
      edition = Generators.valid_edition(title: "something", state: "published")
      edition = Guide.new(slug: "/something", latest_edition: edition)
      edition.valid?
      expect(edition.errors.full_messages_for(:slug)).to eq ["Slug must be be prefixed with /service-manual/"]
    end
  end

end
