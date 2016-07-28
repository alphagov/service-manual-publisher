require 'rails_helper'

RSpec.describe GuidePresenter do
  let(:edition) do
    Edition.new(
      title:               "The Title",
      state:               "draft",
      phase:               "beta",
      description:         "Description",
      update_type:         "major",
      body:                "# Heading",
      updated_at:          Time.now,
      change_summary:      "Add a new guide 'The Title'",
      change_note:         "We added this guide so we can test the presenter"
    )
  end

  let(:guide) do
    Guide.new(
      content_id: "220169e2-ae6f-44f5-8459-5a79e0a78537",
      editions: [edition],
      slug: '/service/manual/test'
    )
  end

  let(:presenter) { described_class.new(guide, edition) }

  describe "#content_payload" do
    it "conforms to the schema" do
      expect(presenter.content_payload).to be_valid_against_schema('service_manual_guide')
    end

    context 'when the guide has a change history' do
      it 'conforms to the schema' do
        guide = create_guide_with_history
        presenter = described_class.new(guide, guide.editions.last)
        expect(presenter.content_payload).to be_valid_against_schema('service_manual_guide')
      end
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
        format: "service_manual_guide",
        base_path: "/service/manual/test"
      )
    end

    it 'includes the summary of, and reason for, the latest change' do
      expect(presenter.content_payload[:details]).to include(
        latest_change_note: "Add a new guide 'The Title'",
        latest_change_reason_for_change: "We added this guide so we can test the presenter"
      )
    end

    it 'includes the previous change history for the guide' do
      guide = create_guide_with_history

      presenter = described_class.new(guide, guide.editions.last)

      expect(presenter.content_payload[:details]).to include(
        change_history: [
          {
            public_timestamp: "2016-07-01T14:16:21Z",
            note: "Update the guide",
            reason_for_change: "Needed to be better",
          },
          {
            public_timestamp: "2016-06-25T14:16:21Z",
            note: "Create the guide",
            reason_for_change: "Because we want to"
          }
        ],
        latest_change_note: "Revise everything",
        latest_change_reason_for_change: "Needed to be even better than that"
      )
    end

    it 'does not duplicate history when the latest edition is the published edition' do
      guide = create(:guide, :with_published_edition)

      presenter = described_class.new(guide, guide.editions.last)

      expect(presenter.content_payload[:details]).to include(
        change_history: [],
        latest_change_note: "change summary",
        latest_change_reason_for_change: "change note"
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
  end

  describe '#links_payload' do
    it "includes an organisation" do
      expect(
        presenter.links_payload[:links][:organisations]
      ).to match_array([an_instance_of(String)])
    end

    it 'returns an empty hash without a content owner' do
      expect(presenter.links_payload[:links][:content_owners]).to be_nil
    end

    it 'returns the content owner if present' do
      edition.content_owner = build(:guide_community)
      expect(presenter.links_payload[:links][:content_owners]).to eq(
        [edition.content_owner.content_id]
      )
    end
  end

private

  def create_guide_with_history
    first_edition = {
      change_summary: "Create the guide",
      change_note: "Because we want to",
      update_type: "major",
      created_at: "2016-06-25T14:16:21Z"
    }

    second_edition = {
      change_summary: "",
      change_note: "",
      update_type: "minor",
      created_at: "2016-06-28T14:16:21Z"
    }

    third_edition = {
      change_summary: "Update the guide",
      change_note: "Needed to be better",
      update_type: "major",
      created_at: "2016-07-01T14:16:21Z"
    }

    current_edition = {
      change_summary: "Revise everything",
      change_note: "Needed to be even better than that",
      update_type: "major",
      created_at: "2016-07-25T14:16:21Z"
    }

    editions = [
      build(:edition, :draft, **first_edition),
      build(:edition, :review_requested, **first_edition),
      build(:edition, :ready, **first_edition),
      build(:edition, :published, **first_edition),

      build(:edition, :draft, **second_edition),
      build(:edition, :review_requested, **second_edition),
      build(:edition, :ready, **second_edition),
      build(:edition, :published, **second_edition),

      build(:edition, :draft, **third_edition),
      build(:edition, :review_requested, **third_edition),
      build(:edition, :ready, **third_edition),
      build(:edition, :published, **third_edition),

      build(:edition, :draft, **current_edition)
    ]

    create(:guide, editions: editions)
  end
end

RSpec.describe GuidePresenter, "for a Point" do
  it "includes the service standard as a parent in the links" do
    edition = create(:edition)
    point = create(:point, editions: [edition])

    presenter = described_class.new(point, edition)

    expect(presenter.links_payload[:links]).to include(
      parent: ["00f693d4-866a-4fe6-a8d6-09cd7db8980b"]
    )
  end

  it "includes the show_description boolean in the details" do
    edition = create(:edition)
    point = create(:point, editions: [edition])

    presenter = described_class.new(point, edition)

    expect(presenter.content_payload[:details][:show_description]).to eq(true)
  end
end
