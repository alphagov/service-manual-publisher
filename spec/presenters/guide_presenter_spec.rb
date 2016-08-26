require 'rails_helper'

RSpec.describe GuidePresenter do
  let(:guide) do
    create(:guide,
      content_id: "220169e2-ae6f-44f5-8459-5a79e0a78537",
      edition: {
        title: "The Title",
        state: "draft",
        phase: "beta",
        description: "Description",
        update_type: "major",
        body: "# Heading",
        created_at: "2016-06-28T14:16:21Z".to_time,
        updated_at: "2016-06-28T14:16:21Z".to_time,
        change_note: "Add a new guide 'The Title'",
        reason_for_change: "We added this guide so we can test the presenter"
      },
      slug: '/service-manual/test-topic/the-title'
    )
  end

  let(:edition) { guide.latest_edition }

  let(:presenter) { described_class.new(guide, edition) }

  describe "#content_payload" do
    it "conforms to the schema" do
      expect(presenter.content_payload).to be_valid_against_schema('service_manual_guide')
    end

    describe "common service manual draft payload" do
      let(:payload) { presenter.content_payload }

      include_examples "common service manual draft payload"
    end

    it "exports all necessary metadata" do
      expect(presenter.content_payload).to include(
        description: "Description",
        update_type: "major",
        phase: "beta",
        schema_name: "service_manual_guide",
        document_type: "service_manual_guide",
        base_path: "/service-manual/test-topic/the-title"
      )
    end

    it "includes the change history for the edition" do
      expect(presenter.content_payload[:details]).to include(
        change_history: [
          {
            public_timestamp: "2016-06-28T14:16:21Z",
            note: "Add a new guide 'The Title'",
            reason_for_change: "We added this guide so we can test the presenter"
          }
        ]
      )
    end

    it "includes the latest change note for email notifications" do
      expect(presenter.content_payload[:details]).to include(
        change_note: "Add a new guide 'The Title'"
      )
    end

    it "omits the content owner if the edition doesn't have one" do
      edition.content_owner = nil

      expect(presenter.content_payload[:details][:content_owner]).to be_blank
    end

    it "includes h2 links for the sidebar" do
      edition.body = "## Header 1 \n\n### Subheader \n\n## Header 2\n\ntext"
      expect(presenter.content_payload[:details][:header_links]).to match_array([
        { title: "Header 1", href: "#header-1" },
        { title: "Header 2", href: "#header-2" }
      ])
    end

    it "renders body to HTML" do
      edition.body = "__look at me__"
      expect(presenter.content_payload[:details][:body]).to include("<strong>look at me</strong>")
    end

    it "exports the title" do
      edition.title = "Agile Process"
      expect(presenter.content_payload[:title]).to eq("Agile Process")
    end

    context 'for a point' do
      it "includes the show_description boolean in the details" do
        edition = create(:edition)
        point = create(:point, editions: [edition])

        presenter = described_class.new(point, edition)

        expect(presenter.content_payload[:details][:show_description]).to eq(true)
      end
    end
  end

  describe '#links_payload' do
    it "includes an organisation" do
      expect(
        presenter.links_payload[:links][:organisations]
      ).to match_array([an_instance_of(String)])
    end

    it 'includes a reference to the service manual topic' do
      expect(
        presenter.links_payload[:links][:service_manual_topics]
      ).to match_array([guide.topic[:content_id]])
    end

    it 'returns the content owner if present' do
      edition.content_owner = build(:guide_community)
      expect(presenter.links_payload[:links][:content_owners]).to eq(
        [edition.content_owner.content_id]
      )
    end

    context 'for a guide community' do
      let(:guide) { create(:guide_community) }

      it "doesn't include content owners" do
        expect(presenter.links_payload[:links]).not_to have_key(:content_owners)
      end
    end

    context 'for a point' do
      let(:guide) { create(:point) }

      it "doesn't include a link to a topic" do
        expect(presenter.links_payload[:links]).not_to have_key(:service_manual_topics)
      end

      it "doesn't include content owners" do
        expect(presenter.links_payload[:links]).not_to have_key(:content_owners)
      end

      it "includes the service standard as a parent in the links" do
        expect(presenter.links_payload[:links]).to include(
          parent: ["00f693d4-866a-4fe6-a8d6-09cd7db8980b"]
        )
      end
    end
  end
end
