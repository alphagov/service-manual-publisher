require 'rails_helper'

RSpec.describe Guide do
  describe "#ensure_draft_exists" do
    let(:edition) { Generators.valid_published_edition }
    let(:guide) do
      Guide.create!(slug: "/service-manual/slug", latest_edition: edition)
    end

    it "does nothing if the latest edition is in a draft state" do
      edition.update_attribute(:state, "draft")

      guide.ensure_draft_exists

      expect(guide.latest_edition).to eq edition
      expect(guide.editions.count).to eq 1
    end

    it "builds an saves a draft copy of the latest edition if it's published" do
      edition.update_attribute(:state, "published")

      guide.ensure_draft_exists

      expect(guide.latest_edition).to_not eq edition
      expect(guide.editions.published.count).to eq 1
      expect(guide.editions.draft.count).to eq 1
    end
  end

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

  describe "#search" do
    it "has triggers setup" do
      expect(HairTrigger::migrations_current?).to be true
    end

    it "searches title" do
      titles = ["Standups", "Unit Testing"]
      titles.each_with_index do |title, index|
        edition = Generators.valid_edition(state: "review_requested", title: title)
        Guide.create!(latest_edition: edition, slug: "/service-manual/#{index}")
      end

      results = Guide.search("testing").map {|e| e.latest_edition.title}
      expect(results).to eq ["Unit Testing"]
    end

    it "prioritises title over body" do
      edition = Generators.valid_edition(state: "review_requested", title: "nothing", body: "search")
      Guide.create!(latest_edition: edition, slug: "/service-manual/1")

      edition = Generators.valid_edition(state: "review_requested", title: "search", body: "nothing")
      Guide.create!(latest_edition: edition, slug: "/service-manual/2")

      results = Guide.search("search").map {|e| e.latest_edition.title}
      expect(results).to eq ["search", "nothing"]
    end
  end

end
