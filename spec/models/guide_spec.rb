require 'rails_helper'

RSpec.describe Guide do
  let(:edition) { build(:published_edition) }

  context "with a topic" do
    let(:guide) do
      create(:guide, slug: "/service-manual/topic-name/slug", editions: [ edition ])
    end

    let!(:topic) do
      topic = create(:topic)
      topic_section = topic.topic_sections.create!(
        "title"       => "Title",
        "description" => "Description",
      )
      topic_section.guides << guide
      topic
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
      Guide.create!(slug: "/service-manual/topic-name/slug", editions: [ edition ])
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
      guide = Guide.create!(slug: "/service-manual/topic-name/slug", content_id: nil, editions: [ edition ])
      expect(guide.content_id).to be_present
    end
  end

  describe "validations" do
    it "doesn't allow slugs without /service-manual/ prefix" do
      guide = Guide.new(slug: "/something", editions: [ edition ])
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug must be present and start with '/service-manual/'"]
    end

    it "requires a topic section" do
      guide = Guide.new
      guide.valid?
      expect(guide).to_not be_valid
      expect(guide.errors.full_messages_for(:topic_section_id)).to eq ["Topic section must be set"]
    end

    it "reminds users if they've forgotten to change the default pre-filled slug value" do
      guide = Guide.new(slug: "/service-manual/", editions: [ edition ])
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug must be filled in"]
    end

    it "ensures that slugs aren't saved without the topic name in the path" do
      guide = Guide.new(slug: "/service-manual/guide-path")
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug must be present and start with '/service-manual/[topic]'"]
    end

    it "does not allow unsupported characters in slugs" do
      guide = Guide.new(slug: "/service-manual/financing$$$.xml}", editions: [ edition ])
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug can only contain letters, numbers and dashes"]
    end

    describe "content owner" do
      it "requires the latest edition to have a content owner" do
        edition_without_content_owner = build(:edition, content_owner: nil)
        guide = build(:guide, editions: [ edition_without_content_owner ])
        guide.valid?

        expect(guide.errors.full_messages_for(:latest_edition)).to include('Latest edition must have a content owner')
      end

      it "requires the latest edition to have a content owner unless it is a GuideCommunity" do
        edition = build(:edition, content_owner: nil)
        guide = build(:guide_community, editions: [ edition ])
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
        author:         build(:user),
      }
    end

    it "searches title" do
      titles = ["Standups", "Unit Testing"]
      titles.each_with_index do |title, index|
        edition = build(:review_requested_edition, title: title)
        create(:guide, slug: "/service-manual/topic-name/#{index}", editions: [ edition ])
      end

      results = Guide.search("testing").map {|e| e.latest_edition.title}
      expect(results).to eq ["Unit Testing"]
    end

    it "does not return duplicates" do
      edition1 = Edition.new(
        default_attributes.merge(
          version: 1, state: "draft", title: "dictionary"
        ),
      )
      edition2 = Edition.new(
        default_attributes.merge(
          version: 1, state: "published", title: "thesaurus"
        ),
      )

      Guide.create!(editions: [edition1, edition2], slug: "/service-manual/topic-name/guide")

      expect(Guide.search("dictionary").count).to eq 0
      expect(Guide.search("thesaurus").count).to eq 1
    end

    it "searches for slug" do
      edition = Edition.new(default_attributes.merge(version: 1, title: "1"))
      Guide.create!(editions: [ edition ], slug: "/service-manual/topic-name/1")

      edition = Edition.new(default_attributes.merge(version: 1, title: "2"))
      Guide.create!(editions: [ edition ], slug: "/service-manual/topic-name/2")

      results = Guide.search("/service-manual/2").map {|e| e.latest_edition.title}
      expect(results).to eq ["2"]
    end
  end

end

RSpec.describe Guide, "#latest_edition_per_edition_group" do
  it "returns only the latest edition from editions that share the same edition number" do
    guide = Guide.new(slug: "/service-manual/topic-name/slug")
    guide.editions << build(:edition, version: 1, created_at: 2.days.ago)
    first_version_second_edition = build(:edition, version: 1, created_at: 1.days.ago)
    guide.editions << first_version_second_edition
    guide.editions << build(:edition, version: 2, created_at: 2.days.ago)
    second_version_second_edition = build(:edition, version: 2, created_at: 1.days.ago)
    guide.editions << second_version_second_edition
    guide.save!

    expect(
      guide.latest_edition_per_edition_group
      ).to eq([second_version_second_edition, first_version_second_edition])
  end
end

RSpec.describe Guide, "#editions_since_last_published" do
  it "returns editions since last published" do
    guide = create(:published_guide)
    edition1 = build(:edition)
    edition2 = build(:edition)
    guide.editions << edition1
    guide.editions << edition2

    expect(guide.editions_since_last_published.to_a).to eq [edition1, edition2]
  end
end

RSpec.describe Guide, "#can_be_unpublished?" do
  let :guide do
    create(:guide)
  end

  it "returns true if the guide has been published" do
    guide.editions << create(:published_edition)
    expect(guide.can_be_unpublished?).to be true
  end

  it "returns false if the guide has been unpublished" do
    guide.editions << create(:published_edition)
    guide.editions << create(:unpublished_edition)
    expect(guide.can_be_unpublished?).to be false
  end
end
