require 'rails_helper'

RSpec.describe GuideForm, "#initialize" do
  context "for a brand new guide" do
    it "assigns an incomplete default slug value" do
      expect(
        described_class.new(guide: Guide.new, edition: Edition.new, user: User.new).slug
        ).to eq("/service-manual/")
    end

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
  end

  context "for an existing guide" do
    it "loads the author_id" do
      edition = build(:edition, body: "A great body")
      guide = create(:guide, editions: [ edition ])
      author = edition.author

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).author_id
        ).to eq(author.id)
    end

    it "loads the body" do
      edition = build(:edition, body: "A great body")
      guide = create(:guide, editions: [ edition ])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).body
        ).to eq("A great body")
    end

    it "loads the content_owner_id" do
      guide_community = create(:guide_community)
      edition = build(:edition, content_owner: guide_community)
      guide = create(:guide, editions: [ edition ])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).content_owner_id
        ).to eq(guide_community.id)
    end

    it "loads the description" do
      edition = build(:edition, description: "Whales should live in Wales")
      guide = create(:guide, editions: [ edition ])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).description
        ).to eq("Whales should live in Wales")
    end

    it "loads the title" do
      edition = build(:edition, title: "U wot")
      guide = create(:guide, editions: [ edition ])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).title
        ).to eq("U wot")
    end

    it "loads the type" do
      edition = build(:edition, content_owner: nil)
      guide = create(:guide_community, editions: [ edition ])

      expect(
        described_class.new(guide: guide, edition: edition, user: User.new).type
        ).to eq("GuideCommunity")
    end

    it "loads the change note and summary" do
      edition = build(:edition, change_summary: "summary", change_note: "note")
      guide = create(:guide, editions: [ edition ])

      guide_form = described_class.new(guide: guide, edition: edition, user: User.new)

      expect(guide_form.change_summary).to eq("summary")
      expect(guide_form.change_note).to eq("note")
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
        build(:edition, state: "published", title: title, update_type: "major", change_summary: "summary", change_note: "note"),
      ])
      edition = guide.editions.build(guide.latest_edition.dup.attributes)
      user = User.new

      guide_form = described_class.new(guide: guide, edition: edition, user: user)

      expect(guide_form.change_summary).to eq(nil)
      expect(guide_form.change_note).to eq(nil)
    end

    it "defaults the author_id to represent the current user again" do
      title = "A guide to agile"
      guide = create(:guide, editions: [
        build(:edition, state: "draft", title: title, update_type: "major"),
        build(:edition, state: "review_requested", title: title, update_type: "major"),
        build(:edition, state: "ready", title: title, update_type: "major"),
        build(:edition, state: "published", title: title, update_type: "major", change_summary: "summary", change_note: "note"),
      ])
      edition = guide.editions.build(guide.latest_edition.dup.attributes)
      user = User.new(id: 8)

      guide_form = described_class.new(guide: guide, edition: edition, user: user)

      expect(guide_form.author_id).to eq(8)
    end
  end
end

RSpec.describe GuideForm, "#save" do
  context "for a brand new guide" do
    it "persists a guide with an edition" do
      guide_community = create(:guide_community)
      user = create(:user)

      guide = Guide.new
      edition = guide.editions.build
      guide_form = described_class.new(guide: guide, edition: edition, user: user)
      guide_form.assign_attributes({
        body: "a fair old body",
        content_owner_id: guide_community.id,
        description: "a pleasant description",
        slug: "/service-manual/topic/a-fair-tale",
        title: "A fair tale",
        update_type: "minor",
        })
      guide_form.save

      expect(guide).to be_persisted
      expect(edition).to be_persisted
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
      guide_form.assign_attributes({author_id: 5})
      guide_form.save

      expect(edition.author_id).to eq(5)
    end
  end

  context "for a published guide" do
    it "increments the version number" do
      guide = create(:published_guide)
      edition = guide.editions.build(guide.latest_edition.dup.attributes)
      user = User.new

      expect(guide.latest_edition.version).to eq(1)

      guide_form = described_class.new(guide: guide, edition: edition, user: user)
      guide_form.save

      expect(edition.version).to eq(2)
    end
  end
end

RSpec.describe GuideForm, "validations" do
  it "passes validation errors up from the models" do
    guide = Guide.new
    edition = guide.editions.build
    guide_form = described_class.new(guide: guide, edition: edition, user: User.new)
    guide_form.save

    expect(
      guide_form.errors.full_messages
      ).to include(
        "Slug must be filled in",
        "Latest edition must have a content owner",
        "Editions is invalid",
        "Description can't be blank",
        "Title can't be blank",
        "Body can't be blank",
        )
  end
end

RSpec.describe GuideForm, "#to_param" do
  it "is the guide id" do
    guide = Guide.new(id: 5)
    edition = guide.editions.build
    user = User.new
    guide_form = described_class.new(guide: guide, edition: edition, user: user)

    expect(guide_form.to_param).to eq("5")
  end
end
