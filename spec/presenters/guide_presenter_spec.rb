require "rails_helper"

RSpec.describe GuidePresenter do
  describe "#content_payload" do
    it "conforms to the schema" do
      guide = create(:guide)
      presenter = described_class.new(guide, guide.latest_edition)

      expect(presenter.content_payload).to be_valid_against_schema("service_manual_guide")
    end

    describe "common service manual draft payload" do
      let(:payload) {
        guide = create(:guide)
        presenter = described_class.new(guide, guide.latest_edition)
        presenter.content_payload
      }

      include_examples "common service manual draft payload"
    end

    it "exports all necessary metadata" do
      guide = create(:guide,
                     edition: {
                       phase: "beta",
                       update_type: "major",
                       description: "Description",
                     },
                     slug: "/service-manual/test-topic/the-title")
      presenter = described_class.new(guide, guide.latest_edition)

      expect(presenter.content_payload).to include(
        description: "Description",
        update_type: "major",
        phase: "beta",
        schema_name: "service_manual_guide",
        document_type: "service_manual_guide",
        base_path: "/service-manual/test-topic/the-title",
      )
    end

    it "includes the change history for the edition" do
      guide = create(:guide,
                     edition: {
                       created_at: "2016-06-28T14:16:21Z".to_time,
                       change_note: "Add a new guide 'The Title'",
                     })
      presenter = described_class.new(guide, guide.latest_edition)

      expect(presenter.content_payload[:details]).to include(
        change_history: [
          {
            public_timestamp: "2016-06-28T14:16:21Z",
            note: "Add a new guide 'The Title'",
          },
        ],
      )
    end

    it "includes the latest change note for email notifications" do
      guide = create(:guide, edition: { change_note: "Add a new guide" })
      presenter = described_class.new(guide, guide.latest_edition)

      expect(presenter.content_payload[:details]).to include(
        change_note: "Add a new guide",
      )
    end

    it "omits the content owner if the edition doesn't have one" do
      guide = create(:guide, edition: { content_owner: nil })
      presenter = described_class.new(guide, guide.latest_edition)

      expect(presenter.content_payload[:details][:content_owner]).to be_blank
    end

    it "includes h2 links for the sidebar" do
      guide = create(:guide, body: "## Header 1 \n\n### Subheader \n\n## Header 2\n\ntext")
      presenter = described_class.new(guide, guide.latest_edition)

      expect(presenter.content_payload[:details][:header_links]).to match_array([
        { title: "Header 1", href: "#header-1" },
        { title: "Header 2", href: "#header-2" },
      ])
    end

    it "renders body to HTML" do
      guide = create(:guide, body: "__look at me__")
      presenter = described_class.new(guide, guide.latest_edition)

      expect(presenter.content_payload[:details][:body]).to include("<strong>look at me</strong>")
    end

    it "exports the title" do
      guide = create(:guide, title: "Agile Process")
      presenter = described_class.new(guide, guide.latest_edition)

      expect(presenter.content_payload[:title]).to eq("Agile Process")
    end

    context "for a point" do
      it "includes the show_description boolean in the details" do
        edition = create(:edition)
        point = create(:point, editions: [edition])

        presenter = described_class.new(point, edition)

        expect(presenter.content_payload[:details][:show_description]).to eq(true)
      end
    end
  end

  describe "#links_payload" do
    context "for all types of guide" do
      it "includes the GDS Organisation ID" do
        guide = create(:guide)
        presenter = described_class.new(guide, guide.latest_edition)

        expect(presenter.links_payload[:links][:organisations])
          .to eq %w[af07d5a5-df63-4ddc-9383-6a666845ebe9]
      end

      it "includes a reference to the service manual topic" do
        topic = create(:topic, content_id: "4ac0bacf-0062-47fd-b1ce-852a95c25e20")
        guide = create(:guide, topic: topic)
        presenter = described_class.new(guide, guide.latest_edition)

        expect(presenter.links_payload[:links][:service_manual_topics])
          .to eq %w[4ac0bacf-0062-47fd-b1ce-852a95c25e20]
      end

      it "returns the content owner if present" do
        owner = create(:guide_community, content_id: "c5eb647c-7943-49dd-8362-1920d330696f")
        guide = create(:guide, edition: { content_owner_id: owner.id })
        presenter = described_class.new(guide, guide.latest_edition)

        expect(presenter.links_payload[:links][:content_owners])
          .to eq(%w[c5eb647c-7943-49dd-8362-1920d330696f])
      end

      it "includes the GDS Organisation ID as the primary publishing organisation" do
        guide = create(:guide)
        presenter = described_class.new(guide, guide.latest_edition)

        expect(presenter.links_payload[:links][:primary_publishing_organisation])
          .to eq %w[af07d5a5-df63-4ddc-9383-6a666845ebe9]
      end
    end

    context "for a guide community" do
      it "doesn't include content owners" do
        guide = create(:guide_community)
        presenter = described_class.new(guide, guide.latest_edition)

        expect(presenter.links_payload[:links]).not_to have_key(:content_owners)
      end
    end

    context "for a point" do
      it "doesn't include a link to a topic" do
        guide = create(:point)
        presenter = described_class.new(guide, guide.latest_edition)

        expect(presenter.links_payload[:links]).not_to have_key :service_manual_topics
      end

      it "doesn't include content owners" do
        guide = create(:point)
        presenter = described_class.new(guide, guide.latest_edition)

        expect(presenter.links_payload[:links]).not_to have_key :content_owners
      end

      it "includes the service standard as a parent in the links" do
        guide = create(:point)
        presenter = described_class.new(guide, guide.latest_edition)

        expect(presenter.links_payload[:links]).to include(
          parent: %w[00f693d4-866a-4fe6-a8d6-09cd7db8980b],
        )
      end
    end
  end
end
