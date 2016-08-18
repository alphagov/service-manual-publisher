require 'rails_helper'

RSpec.describe TopicPresenter, "#content_payload" do
  it "conforms to the schema" do
    topic_presenter = described_class.new(build(:topic))

    expect(topic_presenter.content_payload).to be_valid_against_schema('service_manual_topic')
  end

  describe "common service manual draft payload" do
    let(:payload) { described_class.new(build(:topic)).content_payload }

    include_examples "common service manual draft payload"
  end

  it "exports all necessary metadata" do
    topic = build(
      :topic,
      description: "Topic description",
      path: "/service-manual/test-topic"
    )
    topic_presenter = described_class.new(topic)

    expect(topic_presenter.content_payload).to include(
      description: "Topic description",
      update_type: "minor",
      phase: "beta",
      schema_name: "service_manual_topic",
      document_type: "service_manual_topic",
      base_path: "/service-manual/test-topic"
    )
  end

  it "sets visually_collapsed" do
    topic = build(:topic, visually_collapsed: true)
    topic_presenter = described_class.new(topic)

    expect(
      topic_presenter.content_payload[:details][:visually_collapsed]
    ).to eq(true)
  end

  describe "with topic sections" do
    it "transforms nested guides into the groups format" do
      guide_1 = create(:guide)
      guide_2 = create(:guide)
      guide_3 = create(:guide)

      topic = create(:topic)
      create(
        :topic_section,
        title: "Group 1",
        description: "Fruits",
        topic: topic,
        guides: [guide_1, guide_2]
      )
      create(
        :topic_section,
        topic: topic,
        title: "Group 2",
        description: "Berries",
        guides: [guide_3]
      )

      topic_presenter = described_class.new(topic)
      expect(topic_presenter.content_payload[:details][:groups]).to match_array(
        [
          { name: "Group 1", description: "Fruits", content_ids: match_array([guide_1.content_id, guide_2.content_id]) },
          { name: "Group 2", description: "Berries", content_ids: [guide_3.content_id] },
        ]
      )
    end
  end
end

RSpec.describe TopicPresenter, "#links_payload" do
  it "includes an organisation" do
    guide1 = create(:guide, :with_draft_edition)
    topic = create_topic_in_groups([[guide1]])
    presented_topic = described_class.new(topic)

    links = presented_topic.links_payload[:links]

    expect(
      links[:organisations]
    ).to match_array([an_instance_of(String)])
  end

  it "references all content_ids that appear in groups" do
    guide1 = create(:guide, :with_draft_edition)
    guide2 = create(:guide, :with_draft_edition)
    guide3 = create(:guide, :with_draft_edition)
    topic = create_topic_in_groups([[guide1], [guide2, guide3]])
    presented_topic = described_class.new(topic)

    linked_items = presented_topic.links_payload[:links][:linked_items]

    [guide1, guide2, guide3].each do |guide|
      expect(guide.content_id).to be_in(linked_items)
    end
  end

  it "contains content_owners content ids" do
    guide1 = create(:guide, :with_draft_edition)
    guide2 = create(:guide, :with_draft_edition)
    guide3 = create(:guide, :with_draft_edition)
    topic = create_topic_in_groups([[guide1], [guide2, guide3]])
    presented_topic = described_class.new(topic)

    guide_community_content_ids = [guide1, guide2, guide3].map do |guide|
      guide.latest_edition.content_owner.content_id
    end

    content_owner_content_ids = presented_topic.links_payload[:links][:content_owners]

    expect(content_owner_content_ids).to match_array(guide_community_content_ids)
  end

  it "contains unique content_owners content ids" do
    guide_community = create(:guide_community)
    guide1 = create(:guide, editions: [build(:edition, content_owner: guide_community)])
    guide2 = create(:guide, editions: [build(:edition, content_owner: guide_community)])
    topic = create_topic_in_groups([[guide1], [guide2]])
    presented_topic = described_class.new(topic)

    content_owner_content_ids = presented_topic.links_payload[:links][:content_owners]

    expect(content_owner_content_ids).to eq([guide_community.content_id])
  end

  it "doesn't contain community content_owners because communities don't have them" do
    guide_community = create(:guide_community)
    topic = create_topic_in_groups([[guide_community]])

    presented_topic = described_class.new(topic)

    expect(
      presented_topic.links_payload[:links][:content_owners]
    ).to eq([])
  end

  def create_topic_in_groups(groups)
    topic = create(:topic)
    groups.each do |group_guides|
      create(
        :topic_section,
        topic: topic,
        guides: group_guides
      )
    end
    topic
  end
end
