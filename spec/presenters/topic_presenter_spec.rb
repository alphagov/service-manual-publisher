require 'rails_helper'

RSpec.describe TopicPresenter do
  let(:edition_1) { Generators.valid_edition(title: "Edition 1", guide: Generators.valid_guide).tap(&:save!) }
  let(:edition_2) { Generators.valid_edition(title: "Edition 2", guide: Generators.valid_guide).tap(&:save!) }
  let(:edition_3) { Generators.valid_edition(title: "Edition 3", guide: Generators.valid_guide).tap(&:save!) }
  let(:topic) do
    Topic.create!(
      title: "Test topic",
      path: "/service-manual/test-topic",
      description: "Topic description",
      tree: [{ title: "Group 1",
               editions: [edition_1.id, edition_2.id],
               description: "Fruits"
             }, {
               title: "Group 2",
               editions: [edition_3.id],
               description: "Berries"
             }].to_json
    )
  end

  let(:presented_topic) { described_class.new(topic) }

  describe "#exportable_attributes" do
    it "conforms to the schema" do
      expect(presented_topic.exportable_attributes).to be_valid_against_schema('topic')
    end

    it "exports all necessary metadata" do
      expect(presented_topic.exportable_attributes).to include(
        description: "Topic description",
        update_type: "minor",
        phase: "beta",
        publishing_app: "service-manual-publisher",
        rendering_app: "government-frontend",
        format: "topic",
        locale: "en",
        base_path: "/service-manual/test-topic"
      )
    end

    it "transforms nested guides into the groups format" do
      groups = presented_topic.exportable_attributes[:details][:groups]
      expect(groups.size).to eq 2
      expect(groups.first).to include(name: "Group 1", description: "Fruits")
      expect(groups.first[:contents]).to eq [edition_1.guide.slug, edition_2.guide.slug]
      expect(groups.first[:content_ids]).to eq [edition_1.guide.content_id, edition_2.guide.content_id]
      expect(groups.last).to include(name: "Group 2", description: "Berries")
    end
  end

  describe "#links" do
    it "references all content_ids that appear in groups" do
      linked_items = presented_topic.links[:links][:linked_items]
      [edition_1, edition_2, edition_3].each do |edition|
        expect(edition.guide.content_id).to be_in(linked_items)
      end
    end
  end
end
