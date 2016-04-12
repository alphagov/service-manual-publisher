require 'rails_helper'

RSpec.describe TopicPresenter do
  let(:guide_1) { create(:guide) }
  let(:guide_2) { create(:guide) }
  let(:guide_3) { create(:guide) }

  let(:topic) do
    create(:topic,
      title: "Test topic",
      path: "/service-manual/test-topic",
      description: "Topic description",
      tree: [
        {
          title: "Group 1",
          guides: [guide_1.to_param, guide_2.to_param],
          description: "Fruits",
        },
        {
          title: "Group 2",
          guides: [guide_3.to_param],
          description: "Berries",
        }
      ].to_json
    )
  end

  let(:presented_topic) { described_class.new(topic) }

  describe "#content_payload" do
    it "conforms to the schema" do
      expect(presented_topic.content_payload).to be_valid_against_schema('service_manual_topic')
    end

    it "exports all necessary metadata" do
      expect(presented_topic.content_payload).to include(
        description: "Topic description",
        update_type: "minor",
        phase: "beta",
        publishing_app: "service-manual-publisher",
        rendering_app: "government-frontend",
        format: "service_manual_topic",
        locale: "en",
        base_path: "/service-manual/test-topic"
      )
    end

    it "transforms nested guides into the groups format" do
      groups = presented_topic.content_payload[:details][:groups]
      expect(groups.size).to eq 2
      expect(groups.first).to include(name: "Group 1", description: "Fruits")
      expect(groups.first[:contents]).to eq [guide_1.slug, guide_2.slug]
      expect(groups.first[:content_ids]).to eq [guide_1.content_id, guide_2.content_id]
      expect(groups.last).to include(name: "Group 2", description: "Berries")
    end
  end
end

RSpec.describe TopicPresenter, "#links_payload" do
  it "references all content_ids that appear in groups" do
    guide1 = create(:guide, :with_draft_edition)
    guide2 = create(:guide, :with_draft_edition)
    guide3 = create(:guide, :with_draft_edition)
    topic = create_topic_in_groups([[guide1], [guide2, guide3]])
    presented_topic = TopicPresenter.new(topic)

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
    presented_topic = TopicPresenter.new(topic)

    guide_community_content_ids = [guide1, guide2, guide3].map do |guide|
      guide.latest_edition.content_owner.content_id
    end

    content_owner_content_ids = presented_topic.links_payload[:links][:content_owners]

    expect(content_owner_content_ids).to match_array(guide_community_content_ids)
  end

  it "contains unique content_owners content ids" do
    guide_community = create(:guide_community)
    guide1 = create(:guide, latest_edition: build(:edition, content_owner: guide_community))
    guide2 = create(:guide, latest_edition: build(:edition, content_owner: guide_community))
    topic = create_topic_in_groups([[guide1], [guide2]])
    presented_topic = TopicPresenter.new(topic)

    content_owner_content_ids = presented_topic.links_payload[:links][:content_owners]

    expect(content_owner_content_ids).to eq([guide_community.content_id])
  end

  it "doesn't contain community content_owners because communities don't have them" do
    guide_community = create(:guide_community)
    topic = create_topic_in_groups([[guide_community]])

    presented_topic = TopicPresenter.new(topic)

    expect(
      presented_topic.links_payload[:links][:content_owners]
      ).to eq([])
  end

  def create_topic_in_groups(groups)
    tree = groups.map.with_index do |group_guides, index|
      {
        title: "Group #{index} title",
        guides: group_guides.map(&:to_param),
        description: "Group #{index} description",
      }
    end

    Topic.create!(
      title: "Agile Delivery",
      description: "It's a good thing",
      path: "/service-manual/agile-delivery",
      tree: tree)
  end
end
