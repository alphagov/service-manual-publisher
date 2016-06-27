require "rails_helper"

RSpec.describe PointForm, "validations" do
  it "does not require topic_section_id" do
    guide = Point.new
    edition = guide.editions.build
    guide_form = described_class.new(guide: guide, edition: edition, user: User.new)
    guide_form.save

    expect(guide_form.errors.full_messages).to_not include("Topic section can't be blank")
  end
end

RSpec.describe PointForm, "#slug_prefix" do
  it "returns /service-manual/service-standard" do
    guide_form = described_class.new(guide: Guide.new, edition: Edition.new, user: User.new)

    expect(guide_form.slug_prefix).to eq("/service-manual/service-standard")
  end
end

RSpec.describe PointForm, "#save" do
  it "persists a point with an edition and doesn't place it in a topic section" do
    expect(PUBLISHING_API).to receive(:put_content).twice
    expect(PUBLISHING_API).to receive(:patch_links).once

    guide_community = create(:guide_community)
    user = create(:user)

    point = Point.new
    edition = point.editions.build
    guide_form = described_class.new(guide: point, edition: edition, user: user)
    guide_form.assign_attributes(
      body: "a fair old body",
      content_owner_id: guide_community.id,
      description: "a pleasant description",
      slug: "/service-manual/topic/a-fair-tale",
      summary: "This is my nice summary",
      title: "A fair tale",
      update_type: "minor",
    )
    guide_form.save

    expect(point).to be_persisted
    expect(edition).to be_persisted

    expect(TopicSectionGuide.count).to eq(0)
  end

  it "saves all points to the service standard when saving a point" do
    user = create(:user)
    edition = create(:edition, summary: "This is a summary")
    create(:point, editions: [edition])

    point = Point.new
    edition = point.editions.build
    guide_form = described_class.new(guide: point, edition: edition, user: user)
    guide_form.assign_attributes(body: "a fair old body",
      description: "a pleasant description",
      summary: "a exciting summary",
      slug: "/service-manual/service-standard/do-ongoing-user-research",
      title: "Do ongoing user research",
      update_type: "minor",
      )

    # Stub communication with the publishing api for the point
    allow(PUBLISHING_API).to receive(:put_content)
    allow(PUBLISHING_API)
      .to receive(:patch_links)
      .with(an_instance_of(String), hash_including(links: an_instance_of(Hash)))

    # Expect communication with the publishing api for the service
    # standard
    expect(PUBLISHING_API)
      .to receive(:put_content)
      .with(
        an_instance_of(String),
        hash_including(
          details: hash_including(
            points: [
              hash_including(:base_path, :summary, :title),
              hash_including(:base_path, :summary, :title),
            ]
          )
        )
      )

    guide_form.save
  end
end

RSpec.describe PointForm, "validations" do
  it "passes validation errors up from the models" do
    point = Point.new

    edition = point.editions.build
    guide_form = described_class.new(guide: point, edition: edition, user: User.new)
    guide_form.save

    expect(
      guide_form.errors.full_messages
    ).to include(
      "Slug can only contain letters, numbers and dashes",
      "Slug must be present and start with '/service-manual/[topic]'",
      "Editions is invalid",
      "Description can't be blank",
      "Title can't be blank",
      "Body can't be blank",
      "Latest edition must have a summary",
    )
  end
end
