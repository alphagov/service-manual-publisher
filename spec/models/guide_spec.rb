require 'rails_helper'

RSpec.describe Guide do
  before do
    allow_any_instance_of(GovspeakUrlChecker).to receive(:find_broken_urls).and_return []
  end

  let(:edition) { build(:published_edition) }

  describe "#ensure_draft_exists" do
    let(:guide) do
      Guide.create!(slug: "/service-manual/topic-name/slug", latest_edition: edition)
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

  context "with a topic" do
    let(:guide) do
      create(:guide, slug: "/service-manual/topic-name/slug", latest_edition: edition)
    end

    let!(:topic) do
      create(
        :topic,
        tree: [
          {
            "title"       => "Title",
            "description" => "Description",
            "guides"    => [guide.id],
          },
        ],
      )
    end

    describe "#included_in_a_topic?" do
      it "returns true" do
        expect(guide).to be_included_in_a_topic
      end
    end

    describe "#topic" do
      it "returns the topic" do
        expect(guide.topic).to eq topic
      end
    end

  end

  context "without a topic" do
    let(:guide) do
      Guide.create!(slug: "/service-manual/topic-name/slug", latest_edition: edition)
    end

    describe "#included_in_a_topic?" do
      it "returns false" do
        expect(guide).to_not be_included_in_a_topic
      end
    end

    describe "#topic" do
      it "returns nil" do
        expect(guide.topic).to be_nil
      end
    end
  end

  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      guide = Guide.create!(slug: "/service-manual/topic-name/slug", content_id: nil, latest_edition: edition)
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

    it "ensures that slugs aren't saved without the topic name in the path" do
      guide = Guide.new(slug: "/service-manual/guide-path")
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug must be present and start with '/service-manual/[topic]'"]
    end

    it "does not allow unsupported characters in slugs" do
      guide = Guide.new(slug: "/service-manual/financing$$$.xml}", latest_edition: edition)
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug can only contain letters, numbers and dashes"]
    end

    describe "content owner" do
      it "requires the latest edition to have a content owner" do
        edition_without_content_owner = build(:edition, content_owner: nil)
        guide = build(:guide, latest_edition: edition_without_content_owner)
        guide.valid?

        expect(guide.errors.full_messages_for(:latest_edition)).to include('Latest edition must have a content owner')
      end

      it "requires the latest edition to have a content owner unless it is a GuideCommunity" do
        edition = build(:edition, content_owner: nil)
        guide = build(:guide_community, latest_edition: edition)
        guide.valid?

        expect(guide.errors.full_messages_for(:latest_edition)).to be_empty
      end
    end

    context "has a published edition" do
      it "does not allow changing the slug" do
        guide = create(:published_guide)
        guide.slug = "/service-manual/topic-name/something-else"
        guide.valid?
        expect(guide.errors.full_messages_for(:slug)).to eq ["Slug can't be changed if guide has a published edition"]
      end
    end
  end

  describe "#latest_editable_edition" do
    it "returns the latest edition if it's not published" do
      guide = create(:guide)
      expect(guide.reload.latest_editable_edition).to eq guide.reload.latest_edition
    end

    it "returns an unsaved copy of the latest edition if the latter is published" do
      guide = create(:published_guide)
      expect(guide.latest_editable_edition).to be_a_new_record
      expect(guide.reload.latest_editable_edition.title).to eq guide.latest_edition.title
    end

    it "defaults to a 'major' update for a new drafts" do
      edition = build(:published_edition, update_type: "minor")
      guide = create(:published_guide, latest_edition: edition)
      expect(guide.reload.latest_editable_edition.update_type).to eq "major"
    end

    it "returns a new edition for a guide with no latest edition" do
      guide = build(:guide, latest_edition: nil)
      expect(guide.latest_editable_edition).to be_a_new_record
    end
  end

  describe "#with_published_editions" do
    it "only returns published editions" do
      create(:guide, slug: "/service-manual/topic-name/1")
      guide_with_published_editions = create(:published_guide, slug: "/service-manual/topic-name/2")
      expect(Guide.with_published_editions.to_a).to eq [guide_with_published_editions]
    end

    it "does not return duplicates" do
      guide = create(:guide,
        slug: "/service-manual/topic-name/2",
        editions: [
          build(:published_edition),
          build(:published_edition),
        ],
      )
      expect(Guide.with_published_editions.to_a).to eq [guide]
    end
  end

  describe "#search" do
    let :default_attributes do
      {
        title:          "The Title",
        state:          "draft",
        phase:          "beta",
        description:    "Description",
        update_type:    "major",
        change_note:    "change note",
        change_summary: "change summary",
        body:           "# Heading",
        content_owner:  build(:guide_community),
        user:           build(:user),
      }
    end

    it "searches title" do
      titles = ["Standups", "Unit Testing"]
      titles.each_with_index do |title, index|
        edition = build(:review_requested_edition, title: title)
        create(:guide, slug: "/service-manual/topic-name/#{index}", latest_edition: edition)
      end

      results = Guide.search("testing").map {|e| e.latest_edition.title}
      expect(results).to eq ["Unit Testing"]
    end

    it "does not return duplicates" do
      edition1 = Edition.new(
        default_attributes.merge(
          state: "draft", title: "dictionary"
        ),
      )
      edition2 = Edition.new(
        default_attributes.merge(
          state: "published", title: "thesaurus"
        ),
      )

      Guide.create!(editions: [edition1, edition2], slug: "/service-manual/topic-name/guide")

      expect(Guide.search("dictionary").count).to eq 0
      expect(Guide.search("thesaurus").count).to eq 1
    end

    it "searches for slug" do
      edition = Edition.new(default_attributes.merge(title: "1"))
      Guide.create!(latest_edition: edition, slug: "/service-manual/topic-name/1")

      edition = Edition.new(default_attributes.merge(title: "2"))
      Guide.create!(latest_edition: edition, slug: "/service-manual/topic-name/2")

      results = Guide.search("/service-manual/2").map {|e| e.latest_edition.title}
      expect(results).to eq ["2"]
    end
  end

end
