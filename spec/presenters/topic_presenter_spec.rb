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

  describe "#links_payload" do
    it "references all content_ids that appear in groups" do
      linked_items = presented_topic.links_payload[:links][:linked_items]
      [guide_1, guide_2, guide_3].each do |guide|
        expect(guide.content_id).to be_in(linked_items)
      end
    end
  end
end
