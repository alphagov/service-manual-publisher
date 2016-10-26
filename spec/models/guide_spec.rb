require 'rails_helper'

RSpec.describe Guide do
  context "with a topic" do
    let(:guide) do
      create(:guide, slug: "/service-manual/topic-name/slug")
    end

    let!(:topic) do
      topic = create(:topic)
      topic_section = create(
        :topic_section,
        "title"       => "Title",
        "description" => "Description",
        topic: topic
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
      Guide.new(slug: "/service-manual/topic-name/slug")
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
      topic_section = create(:topic_section)
      guide = Guide.new(slug: "/service-manual/topic-name/slug", content_id: nil)
      guide.topic_section_guides.build(topic_section: topic_section)
      guide.save!

      expect(guide.content_id).to be_present
    end
  end

  describe "validations" do
    it "ensures that slugs aren't saved without the topic name in the path" do
      guide = Guide.new(slug: "/service-manual/guide-path")
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq ["Slug must be present and start with '/service-manual/[topic]'"]
    end

    it "does not allow unsupported characters in slugs" do
      guide = Guide.new(slug: "/service-manual/topic-name/$")
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq [
        "Slug can only contain letters, numbers and dashes",
        "Slug must be present and start with '/service-manual/[topic]'",
      ]

      guide = Guide.new(slug: "/service-manual/$$$/title")
      guide.valid?
      expect(guide.errors.full_messages_for(:slug)).to eq [
        "Slug can only contain letters, numbers and dashes",
        "Slug must be present and start with '/service-manual/[topic]'",
      ]
    end

    describe "content owner" do
      it "requires the latest edition to have a content owner" do
        edition_without_content_owner = build(:edition, content_owner: nil)
        guide = build(:guide, editions: [edition_without_content_owner])
        guide.valid?

        expect(guide.errors.full_messages_for(:latest_edition)).to include('Latest edition must have a content owner')
      end

      it "requires the latest edition to have a content owner unless it is a GuideCommunity" do
        edition = build(:edition, content_owner: nil)
        guide = build(:guide_community, editions: [edition])
        guide.valid?

        expect(guide.errors.full_messages_for(:latest_edition)).to be_empty
      end
    end

    describe "topic section" do
      it "changes to a different topic section within the same topic" do
        topic = create(:topic)
        guide = create(:guide, :with_published_edition, topic: topic)
        original_topic_section = guide.topic_section_guides.first.topic_section
        new_topic_section = create(:topic_section, topic: topic)

        guide.topic_section_guides[0].topic_section_id = new_topic_section.id
        guide.save

        expect(new_topic_section.reload.guides).to include guide
        expect(original_topic_section.reload.guides).to_not include guide
      end

      it "isn't possible to change the topic" do
        original_topic = create(:topic, path: "/service-manual/original-topic")
        original_topic_section = create(:topic_section, topic: original_topic)
        different_topic = create(:topic, path: "/service-manual/different-topic")
        different_topic_section = create(:topic_section, topic: different_topic)
        guide = create(:guide, :with_published_edition)
        original_topic_section.guides << guide

        guide.topic_section_guides[0].topic_section_id = different_topic_section.id
        guide.save

        expect(
          guide.errors.full_messages_for(:topic_section)
        ).to include("Topic section cannot change to a different topic")

        expect(original_topic_section.reload.guides).to include guide
        expect(different_topic_section.reload.guides).to_not include guide
      end
    end

    context "has a published edition" do
      it "does not allow changing the slug" do
        guide = create(:guide, :with_published_edition)
        guide.slug = "/service-manual/topic-name/something-else"
        guide.valid?
        expect(guide.errors.full_messages_for(:slug)).to eq ["Slug can't be changed if guide has a published edition"]
      end
    end
  end

  describe "#search" do
    it "searches titles" do
      create(:guide, title: "Standups")
      create(:guide, title: "Unit Testing")

      results = Guide.search("testing").map(&:title)
      expect(results).to eq ["Unit Testing"]
    end

    it "does not return duplicates" do
      create(:guide, editions: [
        build(:edition, :draft, title: "dictionary"),
        build(:edition, :published, title: "thesaurus")
      ])

      expect(described_class.search("dictionary").count).to eq 0
      expect(described_class.search("thesaurus").count).to eq 1
    end

    it "searches slugs" do
      create(:guide, title: "Guide 1", slug: "/service-manual/topic-name/1")
      create(:guide, title: "Guide 2", slug: "/service-manual/topic-name/2")

      results = Guide.search("/service-manual/topic-name/2").map(&:title)
      expect(results).to eq ["Guide 2"]
    end
  end
end

RSpec.describe Guide, "#latest_edition_per_edition_group" do
  it "returns only the latest edition from editions that share the same edition number" do
    topic_section = create(:topic_section)
    guide = Guide.new(slug: "/service-manual/topic-name/slug")
    guide.editions << build(:edition, version: 1, created_at: 2.days.ago)
    first_version_second_edition = build(:edition, version: 1, created_at: 1.days.ago)
    guide.editions << first_version_second_edition
    guide.editions << build(:edition, version: 2, created_at: 2.days.ago)
    second_version_second_edition = build(:edition, version: 2, created_at: 1.days.ago)
    guide.editions << second_version_second_edition
    guide.topic_section_guides.build(topic_section: topic_section)
    guide.save!

    expect(
      guide.latest_edition_per_edition_group
    ).to eq([second_version_second_edition, first_version_second_edition])
  end
end

RSpec.describe Guide, "#editions_since_last_published" do
  it "returns editions since last published" do
    guide = create(:guide, :with_published_edition)
    edition1 = build(:edition, version: 2)
    edition2 = build(:edition, version: 2)
    guide.editions << edition1
    guide.editions << edition2

    expect(guide.editions_since_last_published.to_a).to match_array [edition2, edition1]
  end
end

RSpec.describe Guide, "#can_be_unpublished?" do
  it "returns true if the guide has been published" do
    guide = create(:guide, :with_published_edition)
    expect(guide.can_be_unpublished?).to be true
  end

  it "returns false if the guide has been unpublished" do
    guide = create(:guide, :has_been_unpublished)
    expect(guide.can_be_unpublished?).to be false
  end
end

RSpec.describe Guide, "#live_edition" do
  it "returns the most recently published edition" do
    guide = create(:guide, created_at: 5.days.ago)
    latest_published_edition = build(:edition, :published, created_at: 3.days.ago)
    guide.editions << latest_published_edition
    guide.editions << create(:edition, :published, created_at: 4.days.ago)

    expect(guide.live_edition).to eq(latest_published_edition)
  end

  it "returns the most recently published edition since unpublication" do
    guide = create(:guide, created_at: 5.days.ago)
    guide.editions << build(:edition, :published, created_at: 4.days.ago)
    guide.editions << build(:edition, :unpublished, created_at: 3.days.ago)
    latest_published_edition = build(:edition, :published, created_at: 2.days.ago)
    guide.editions << latest_published_edition

    expect(guide.live_edition).to eq(latest_published_edition)
  end

  it "returns nil if it has been unpublished since publication" do
    guide = create(:guide, created_at: 5.days.ago)
    guide.editions << create(:edition, :published, created_at: 4.days.ago)
    guide.editions << create(:edition, :unpublished, created_at: 3.days.ago)

    expect(guide.live_edition).to eq(nil)
  end

  it "is nil if an edition hasn't been published yet" do
    guide = create(:guide)

    expect(guide.live_edition).to eq(nil)
  end
end

RSpec.describe Guide, ".in_state" do
  it "returns guides that have a latest edition in a state" do
    published_guide = create(:guide, :with_published_edition)
    ready_guide = create(:guide, :with_ready_edition)
    draft_guide = create(:guide, :with_draft_edition)

    draft_guides = Guide.where(type: nil).in_state("draft")
    expect(draft_guides).to eq [draft_guide]

    ready_guides = Guide.where(type: nil).in_state("ready")
    expect(ready_guides).to eq [ready_guide]

    published_guides = Guide.where(type: nil).in_state("published")
    expect(published_guides).to eq [published_guide]
  end
end

RSpec.describe Guide, ".by_author" do
  it "returns guides that have a latest edition by the author" do
    expected_author = create(:user)
    another_author = create(:user)

    create(:guide, editions: [
      build(:edition, author: expected_author),
      build(:edition, author: another_author),
    ])
    expected_guide = create(:guide, editions: [
      build(:edition, author: another_author),
      build(:edition, author: expected_author),
    ])

    expect(Guide.where(type: nil).by_author(expected_author.id).to_a).to eq [
      expected_guide
    ]
  end
end

RSpec.describe Guide, ".owned_by" do
  it "returns guides with a latest edition owned by the content owner" do
    expected_content_owner = create(:guide_community)
    another_content_owner = create(:guide_community)

    create(
      :guide,
      editions: [
        build(:edition, content_owner: expected_content_owner),
        build(:edition, content_owner: another_content_owner),
      ],
    )
    expected_guide = create(
      :guide,
      editions: [
        build(:edition, content_owner: another_content_owner),
        build(:edition, content_owner: expected_content_owner),
      ],
    )

    expect(Guide.where(type: nil).owned_by(expected_content_owner.id).to_a).to eq [
      expected_guide
    ]
  end
end

RSpec.describe Guide, ".by_type" do
  it "returns guides with a specific type" do
    guide_community_edition = build(:edition, content_owner: nil, title: "Agile Community")
    guide_community = create(:guide_community, editions: [guide_community_edition])

    edition = build(:edition, content_owner: guide_community, title: "Scrum")
    create(:guide, editions: [edition])

    expect(described_class.by_type("GuideCommunity")).to eq([guide_community])
  end

  it "returns guides of type Guide if nil or empty string is supplied" do
    guide_community_edition = build(:edition, content_owner: nil, title: "Agile Community")
    guide_community = create(:guide_community, editions: [guide_community_edition])

    edition = build(:edition, content_owner: guide_community, title: "Scrum")
    guide = create(:guide, editions: [edition])

    expect(described_class.by_type(nil)).to eq([guide])
    expect(described_class.by_type("")).to eq([guide])
  end
end


RSpec.describe Guide, ".live" do
  it "returns guides that are currently published" do
    create(:guide, :with_draft_edition)
    create(:guide, :with_review_requested_edition)
    create(:guide, :with_ready_edition)
    with_published_edition_guide = create(:guide, :with_published_edition)
    with_previously_published_edition_guide = create(:guide, :with_previously_published_edition)
    create(:guide, :has_been_unpublished)

    expect(Guide.live).to match_array([with_published_edition_guide, with_previously_published_edition_guide])
  end
end

RSpec.describe Guide, ".not_unpublished" do
  it "returns guides that are currently published" do
    guide_community = create(:guide_community)

    relevant_traits = [
      :with_draft_edition,
      :with_review_requested_edition,
      :with_ready_edition,
      :with_published_edition,
      :with_previously_published_edition
    ]

    relevant_guides = relevant_traits.map do |trait|
      create(:guide, trait, edition: { content_owner_id: guide_community.id })
    end

    create(:guide, :has_been_unpublished, edition: { content_owner_id: guide_community.id })

    expect(Guide.not_unpublished).to match_array(relevant_guides + [guide_community])
  end
end

RSpec.describe Guide, ".destroy" do
  it "destroys any associated editions" do
    guide = create(:guide, :with_draft_edition)
    guide.destroy

    expect(Edition.where(guide_id: guide.id).count).to eq 0
  end

  it "destroys any associations with topic sections" do
    guide = create(:guide)
    guide.destroy

    expect(TopicSectionGuide.where(guide_id: guide.id).count).to eq 0
  end
end
