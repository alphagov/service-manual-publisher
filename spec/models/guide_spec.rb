require 'rails_helper'

RSpec.describe Guide do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      edition = Generators.valid_published_edition
      guide = Guide.create!(slug: "/service-manual/slug", content_id: nil, latest_edition: edition)
      expect(guide.content_id).to be_present
    end
  end

  describe "validations" do
    it "doesn't allow slugs without /service-manual/ prefix" do
      edition = Generators.valid_published_edition
      edition = Guide.new(slug: "/something", latest_edition: edition)
      edition.valid?
      expect(edition.errors.full_messages_for(:slug)).to eq ["Slug must be be prefixed with /service-manual/"]
    end
  end

  describe "#latest_editable_edition" do
    it "returns the latest edition if it's not published" do
      guide = Guide.create(slug: "/service-manual/ediatble", editions: [Generators.valid_edition])
      expect(guide.latest_editable_edition).to eq guide.reload.latest_edition
    end

    it "returns an unsaved copy of the latest edition if the latter is published" do
      guide = Guide.create(slug: "/service-manual/ediatble", editions: [Generators.valid_published_edition(title: "Agile Methodologies")])

      expect(guide.latest_editable_edition).to be_a_new_record
      expect(guide.latest_editable_edition.title).to eq "Agile Methodologies"
    end

    it "returns a new edition for a guide with no latest edition" do
      expect(Guide.new.latest_editable_edition).to be_a_new_record
    end
  end

  describe "#with_published_editions" do
    it "only returns published editions" do
      Guide.create!(
        slug: "/service-manual/1",
        latest_edition: Generators.valid_edition(state: "draft"),
      )
      guide2 = Guide.create!(
        slug: "/service-manual/2",
        latest_edition: Generators.valid_published_edition,
      )
      expect(Guide.with_published_editions.to_a).to eq [guide2]
    end

    it "does not return duplicates" do
      guide2 = Guide.create!(
        slug: "/service-manual/2",
        editions: [
          Generators.valid_published_edition,
          Generators.valid_published_edition,
        ],
      )
      expect(Guide.with_published_editions.to_a).to eq [guide2]
    end
  end
end
