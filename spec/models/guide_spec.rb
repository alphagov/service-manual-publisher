require 'rails_helper'

RSpec.describe Guide do
  let(:edition) { Generators.valid_published_edition }

  describe '.community_guides' do
    it 'returns community flavoured guides only' do
      design_community_guide = Guide.create!(
        community: true,
        latest_edition: Generators.valid_edition(title: 'Design Community'),
        slug: "/service-manual/design-community"
      )
      Guide.create!(
        latest_edition: Generators.valid_edition(title: 'A proper guide page'),
        slug: "/service-manual/proper-guide"
      )

      expect(Guide.community_guides).to eq([design_community_guide])
    end
  end

  describe "#ensure_draft_exists" do
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
      guide = Guide.create!(slug: "/service-manual/slug", content_id: nil, latest_edition: edition)
      expect(guide.content_id).to be_present
    end
  end

  describe "validations" do
    it "doesn't allow slugs without /service-manual/ prefix" do
      guide = Guide.new(slug: "/something", latest_edition: edition)
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug must be present and start with '/service-manual/'"]
    end

    it "reminds users if they've forgotten to change the default pre-filled slug value" do
      guide = Guide.new(slug: "/service-manual/", latest_edition: edition)
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug must be filled in"]
    end

    it "does not allow unsupported characters in slugs" do
      guide = Guide.new(slug: "/service-manual/financing$$$.xml}", latest_edition: edition)
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug can only contain letters, numbers and dashes"]
    end

    context "has a published edition" do
      it "does not allow changing the slug" do
        guide = Guide.create!(
          slug: "/service-manual/agile",
          latest_edition: Generators.valid_published_edition,
        )
        guide.slug = "/service-manual/something-else"
        guide.valid?
        expect(guide.errors.full_messages_for(:slug)).to eq ["Slug can't be changed if guide has a published edition"]
      end
    end
  end

  describe "#latest_editable_edition" do
    it "returns the latest edition if it's not published" do
      guide = Guide.create(slug: "/service-manual/editable", editions: [Generators.valid_edition])
      expect(guide.latest_editable_edition).to eq guide.reload.latest_edition
    end

    it "returns an unsaved copy of the latest edition if the latter is published" do
      guide = Guide.create(
                slug: "/service-manual/editable",
                editions: [Generators.valid_published_edition(title: "Agile Methodologies")]
              )

      expect(guide.latest_editable_edition).to be_a_new_record
      expect(guide.latest_editable_edition.title).to eq "Agile Methodologies"
    end

    it "defaults to a 'major' update for a new drafts" do
      guide = Guide.create(
                slug: "/service-manual/editable",
                editions: [Generators.valid_published_edition(update_type: "minor")]
              )

      expect(guide.latest_editable_edition.update_type).to eq "major"
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
    it "searches title" do
      titles = ["Standups", "Unit Testing"]
      titles.each_with_index do |title, index|
        edition = Generators.valid_edition(state: "review_requested", title: title)
        Guide.create!(latest_edition: edition, slug: "/service-manual/#{index}")
      end

      results = Guide.search("testing").map {|e| e.latest_edition.title}
      expect(results).to eq ["Unit Testing"]
    end

    it "does not return duplicates" do
      edition1 = Generators.valid_edition(state: "draft", title: "dictionary")
      edition2 = Generators.valid_edition(state: "published", title: "thesaurus")
      Guide.create!(editions: [edition1, edition2], slug: "/service-manual/guide")

      expect(Guide.search("dictionary").count).to eq 0
      expect(Guide.search("thesaurus").count).to eq 1
    end

    it "searches for slug" do
      edition = Generators.valid_edition(title: "1")
      Guide.create!(latest_edition: edition, slug: "/service-manual/1")

      edition = Generators.valid_edition(title: "2")
      Guide.create!(latest_edition: edition, slug: "/service-manual/2")

      results = Guide.search("/service-manual/2").map {|e| e.latest_edition.title}
      expect(results).to eq ["2"]
    end
  end

end
