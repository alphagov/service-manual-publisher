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
      updated_at:          Time.now
    )
  end

  let(:guide) do
    Guide.new(
      content_id: "220169e2-ae6f-44f5-8459-5a79e0a78537",
      latest_edition: edition,
      slug: '/service/manual/test'
    )
  end

  let(:presenter) { described_class.new(guide, edition) }

  describe "#content_payload" do
    it "conforms to the schema" do
      expect(presenter.content_payload).to be_valid_against_schema('service_manual_guide')
    end

    it "exports all necessary metadata" do
      expect(presenter.content_payload).to include(
        description: "Description",
        update_type: "major",
        phase: "beta",
        publishing_app: "service-manual-publisher",
        rendering_app: "government-frontend",
        format: "service_manual_guide",
        locale: "en",
        base_path: "/service/manual/test"
      )
    end

    it "includes related_discusion when it's provided" do
      edition.related_discussion_title = 'Discussion Forum'
      edition.related_discussion_href = 'http://someforum.gov.uk'
      expect(presenter.content_payload[:details][:related_discussion]).to eq(
        title: "Discussion Forum",
        href: "http://someforum.gov.uk"
      )
    end

    it "omits related_discusion when it's not provided" do
      edition.related_discussion_title = ''
      edition.related_discussion_href = ''
      expect(presenter.content_payload[:details][:related_discussion]).to be_blank
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
    it 'returns an empty hash without a content owner' do
      expect(presenter.links_payload).to eq({links: {}})
    end

    it 'returns the content owner if present' do
      edition.content_owner = Generators.valid_guide_community(
        latest_edition: Generators.valid_edition(content_owner: nil, title: 'Technology Community')
        ).tap(&:save!)

      expect(presenter.links_payload).to eq({
        links: {
          content_owners: [edition.content_owner.content_id]
        }
      })
    end
  end
end
