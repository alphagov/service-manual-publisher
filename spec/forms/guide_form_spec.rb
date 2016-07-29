require 'rails_helper'

RSpec.describe GuideForm, ".build" do
  it "returns a GuideForm for a Guide" do
    expect(
      described_class.build(guide: Guide.new, edition: Edition.new, user: User.new)
    ).to be_instance_of GuideForm
  end

  it "returns a PointForm for a Point" do
    expect(
      described_class.build(guide: Point.new, edition: Edition.new, user: User.new)
    ).to be_instance_of PointForm
  end
end

RSpec.describe GuideForm, "#initialize" do
  context "for a brand new guide" do
    it "assigns a default update_type of major" do
      expect(
        described_class.new(guide: Guide.new, edition: Edition.new, user: User.new).update_type
      ).to eq("major")
    end

    it "assigns author_id to be the current user" do
      expect(
        described_class.new(guide: Guide.new, edition: Edition.new, user: User.new(id: 5)).author_id
      ).to eq(5)
    end

    it "assigns title_slug to be nil" do
      expect(
        described_class.new(guide: Guide.new, edition: Edition.new, user: User.new(id: 5)).title_slug
      ).to eq(nil)
    end
  end

  context "for an existing guide" do
    it "loads the author_id" do
      edition = build(:edition, body: "A great body")
      guide = create(:guide, editions: [edition])
      author = edition.author

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).author_id
      ).to eq(author.id)
    end

    it "loads the body" do
      edition = build(:edition, body: "A great body")
      guide = create(:guide, editions: [edition])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).body
      ).to eq("A great body")
    end

    it "loads the content_owner_id" do
      guide_community = create(:guide_community)
      edition = build(:edition, content_owner: guide_community)
      guide = create(:guide, editions: [edition])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).content_owner_id
      ).to eq(guide_community.id)
    end

    it "loads the description" do
      edition = build(:edition, description: "Whales should live in Wales")
      guide = create(:guide, editions: [edition])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).description
      ).to eq("Whales should live in Wales")
    end

    it "loads the title" do
      edition = build(:edition, title: "U wot")
      guide = create(:guide, editions: [edition])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).title
      ).to eq("U wot")
    end

    it "loads the type" do
      edition = build(:edition, content_owner: nil)
      guide = create(:guide_community, editions: [edition])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).type
      ).to eq("GuideCommunity")
    end

    it "loads the change note and summary" do
      edition = build(:edition, change_note: "summary", reason_for_change: "note")
      guide = create(:guide, editions: [edition])

      guide_form = described_class.new(guide: guide, edition: edition, user: User.new)

      expect(guide_form.change_note).to eq("summary")
      expect(guide_form.reason_for_change).to eq("note")
    end

    it "loads the topic_section_id" do
      edition = build(:edition)
      guide = create(:guide, editions: [edition])
      topic = create(:topic)
      topic_section = create(:topic_section, topic: topic)
      TopicSectionGuide.create!(topic_section: topic_section, guide: guide)

      guide_form = described_class.new(guide: guide, edition: edition, user: User.new)

      expect(guide_form.topic_section_id).to eq(topic_section.id)
    end

    it "calculates the title_slug" do
      edition = build(:edition)
      guide = create(:guide, editions: [edition], slug: "/service-manual/topic/my-guide")

      guide_form = described_class.new(guide: guide, edition: edition, user: User.new)

      expect(guide_form.title_slug).to eq("my-guide")
    end
  end

  context "for an existing published guide" do
    it "defaults to an update_type of major" do
      title = "A guide to agile"
      guide = create(:guide, editions: [
        build(:edition, state: "draft", title: title, update_type: "minor"),
        build(:edition, state: "review_requested", title: title, update_type: "minor"),
        build(:edition, state: "ready", title: title, update_type: "minor"),
        build(:edition, state: "published", title: title, update_type: "minor"),
      ])
      edition = guide.editions.build(guide.latest_edition.dup.attributes)
      user = User.new

      guide_form = described_class.new(guide: guide, edition: edition, user: user)

      expect(guide_form.update_type).to eq("major")
    end

    it "clears the change note and summary" do
      title = "A guide to agile"
      guide = create(:guide, editions: [
        build(:edition, state: "draft", title: title, update_type: "major"),
        build(:edition, state: "review_requested", title: title, update_type: "major"),
        build(:edition, state: "ready", title: title, update_type: "major"),
        build(:edition, state: "published", title: title, update_type: "major", change_note: "summary", reason_for_change: "note"),
      ])
      edition = guide.editions.build(guide.latest_edition.dup.attributes)
      user = User.new

      guide_form = described_class.new(guide: guide, edition: edition, user: user)

      expect(guide_form.change_note).to eq(nil)
      expect(guide_form.reason_for_change).to eq(nil)
    end

    it "defaults the author_id to represent the current user again" do
      title = "A guide to agile"
      guide = create(:guide, editions: [
        build(:edition, state: "draft", title: title, update_type: "major"),
        build(:edition, state: "review_requested", title: title, update_type: "major"),
        build(:edition, state: "ready", title: title, update_type: "major"),
        build(:edition, state: "published", title: title, update_type: "major", change_note: "summary", reason_for_change: "note"),
      ])
      edition = guide.editions.build(guide.latest_edition.dup.attributes)
      user = User.new(id: 8)

      guide_form = described_class.new(guide: guide, edition: edition, user: user)

      expect(guide_form.author_id).to eq(8)
    end

    it "increments the version number" do
      user = create(:user)
      guide = create(:guide, :with_published_edition)
      edition = guide.latest_edition

      guide_form = described_class.new(guide: guide, edition: edition, user: user)

      expect(guide_form.version).to eq(2)
    end
  end
end

RSpec.describe GuideForm, "#save" do
  context "for a brand new guide" do
    it "persists a guide with an edition and puts it in the relevant topic section" do
      expect(PUBLISHING_API).to receive(:put_content)
      expect(PUBLISHING_API).to receive(:patch_links)

      guide_community = create(:guide_community)
      user = create(:user)

      topic = create(:topic)
      topic_section = create(:topic_section, topic: topic)

      guide = Guide.new
      edition = guide.editions.build
      guide_form = described_class.new(guide: guide, edition: edition, user: user)
      guide_form.assign_attributes(body: "a fair old body",
        content_owner_id: guide_community.id,
        description: "a pleasant description",
        slug: "/service-manual/topic/a-fair-tale",
        title: "A fair tale",
        update_type: "minor",
        topic_section_id: topic_section.id)
      guide_form.save

      expect(guide).to be_persisted
      expect(edition).to be_persisted

      expect(
        TopicSectionGuide.find_by(topic_section: topic_section, guide: guide)
      ).to be_present
    end

    it "assigns a state of draft" do
      guide = Guide.new
      edition = guide.editions.build
      user = User.new
      guide_form = described_class.new(guide: guide, edition: edition, user: user)
      guide_form.save

      expect(edition.state).to eq("draft")
    end

    it "assigns an initial version of 1" do
      guide = Guide.new
      edition = guide.editions.build
      user = User.new
      guide_form = described_class.new(guide: guide, edition: edition, user: user)
      guide_form.save

      expect(edition.version).to eq(1)
    end

    it "assigns the author to the edition" do
      guide = Guide.new
      edition = guide.editions.build
      user = User.new
      guide_form = described_class.new(guide: guide, edition: edition, user: user)
      guide_form.assign_attributes(author_id: 5)
      guide_form.save

      expect(edition.author_id).to eq(5)
    end

    it "assigns the created_by to the edition" do
      guide = Guide.new
      edition = guide.editions.build
      user = create(:user)
      guide_form = described_class.new(guide: guide, edition: edition, user: user)
      guide_form.assign_attributes(author_id: 5)
      guide_form.save

      expect(edition.created_by).to eq(user)
    end

    it "assigns the changed note and summary to the edition" do
      guide = Guide.new
      edition = guide.editions.build
      user = User.new
      guide_form = described_class.new(guide: guide, edition: edition, user: user)
      guide_form.assign_attributes(
        change_note: "X happened",
        reason_for_change: "This happened because of X.",
      )
      guide_form.save

      expect(edition.change_note).to eq("X happened")
      expect(edition.reason_for_change).to eq("This happened because of X.")
    end
  end

  context "for a published guide" do
    it "doesn't create a duplicate TopicSectionGuide" do
      user = create(:user)
      guide = create(:guide, :with_published_edition)
      edition = guide.latest_edition
      topic = create(:topic)
      topic_section = create(:topic_section, topic: topic)
      topic_section.guides << guide

      expect(PUBLISHING_API).to receive(:put_content).with(guide.content_id, an_instance_of(Hash))
      expect(PUBLISHING_API).to receive(:patch_links).with(guide.content_id, an_instance_of(Hash))

      guide_form = described_class.new(guide: guide, edition: edition, user: user)
      guide_form.assign_attributes(topic_section_id: topic_section.id)
      expect(
        guide_form.save
      ).to eq(true)

      expect(
        TopicSectionGuide.where(guide: guide).count
      ).to eq 1
    end

    it "changes to a different topic section within the same topic" do
      topic = create(:topic)
      original_topic_section = create(:topic_section, topic: topic)
      new_topic_section = create(:topic_section, topic: topic)
      user = create(:user)
      guide = create(:guide, :with_published_edition)
      edition = guide.latest_edition
      original_topic_section.guides << guide

      expect(PUBLISHING_API).to receive(:put_content).with(guide.content_id, an_instance_of(Hash))
      expect(PUBLISHING_API).to receive(:patch_links).with(guide.content_id, an_instance_of(Hash))

      guide_form = described_class.new(
        guide: guide,
        edition: edition,
        user: user
      )
      guide_form.assign_attributes(topic_section_id: new_topic_section.id)
      guide_form.save

      expect(new_topic_section.reload.guides).to include guide
      expect(original_topic_section.reload.guides).to_not include guide
    end

    it "isn't possible to change the topic" do
      original_topic = create(:topic, path: "/service-manual/original-topic")
      original_topic_section = create(:topic_section, topic: original_topic)
      different_topic = create(:topic, path: "/service-manual/different-topic")
      different_topic_section = create(:topic_section, topic: different_topic)
      user = create(:user)
      guide = create(:guide, :with_published_edition)
      edition = guide.latest_edition

      original_topic_section.guides << guide

      guide_form = described_class.new(
        guide: guide,
        edition: edition,
        user: user
      )
      guide_form.assign_attributes(topic_section_id: different_topic_section.id)
      guide_form.save

      expect(
        guide_form.errors.full_messages_for(:topic_section_id)
      ).to include("Topic section cannot change to a different topic")

      expect(original_topic_section.reload.guides).to include guide
      expect(different_topic_section.reload.guides).to_not include guide
    end

    it "does not persist changes if communication with the publishing api fails" do
      gds_api_exception = GdsApi::HTTPErrorResponse.new(422,
                                            'https://some-service.gov.uk',
                                            'error' => { 'message' => 'trouble' })
      expect(PUBLISHING_API).to receive(:put_content).and_raise(gds_api_exception)

      user = create(:user)
      guide = create(:guide, :with_draft_edition)
      edition = guide.latest_edition
      original_body = edition.body
      guide_form = described_class.new(
        guide: guide,
        edition: edition,
        user: user
      )
      guide_form.assign_attributes(body: 'Nice new copy', topic_section_id: 5)

      expect(guide_form.save).to eq(false)
      expect(guide.reload.latest_edition.body).to eq(original_body)
      expect(guide_form.errors.full_messages).to include('trouble')
    end
  end
end

RSpec.describe GuideForm, "validations" do
  it "passes validation errors up from the models" do
    guide = Guide.new

    topic_section = create(:topic_section, topic: create(:topic))

    edition = guide.editions.build
    guide_form = described_class.new(guide: guide, edition: edition, user: User.new)
    guide_form.topic_section_id = topic_section.id
    guide_form.save

    expect(
      guide_form.errors.full_messages
    ).to include(
      "Slug can only contain letters, numbers and dashes",
      "Slug must be present and start with '/service-manual/[topic]'",
      "Latest edition must have a content owner",
      "Description can't be blank",
      "Title can't be blank",
      "Body can't be blank",
    )
  end

  it "validates topic_section_id" do
    guide = Guide.new
    edition = guide.editions.build
    guide_form = described_class.new(guide: guide, edition: edition, user: User.new)
    guide_form.save

    expect(guide_form.errors.full_messages).to include("Topic section can't be blank")
  end
end

RSpec.describe GuideForm, "#to_param" do
  it "returns the guide id" do
    guide = Guide.new(id: 5)
    edition = guide.editions.build
    user = User.new
    guide_form = described_class.new(guide: guide, edition: edition, user: user)

    expect(guide_form.to_param).to eq("5")
  end
end

RSpec.describe GuideForm, "#slug_prefix" do
  it "returns /service-manual" do
    guide_form = described_class.new(guide: Guide.new, edition: Edition.new, user: User.new)

    expect(guide_form.slug_prefix).to eq("/service-manual")
  end
end
