require 'rails_helper'

RSpec.describe GuidePresenter do
  let(:edition) do
    Edition.new(
      title:           "The Title",
      state:           "draft",
      phase:           "beta",
      description:     "Description",
      update_type:     "major",
      body:            "# Heading",
      publisher_title: "Publisher Name",
      updated_at: "2015-10-10"
    )
  end

  let(:guide) do
    Guide.new(
      content_id: "cont-ent-id",
      latest_edition: edition,
      slug: '/service/manual/test'
    )
  end

  let(:presenter) { described_class.new(guide, edition) }

  describe "#exportable_attributes" do
    it "conforms to the schema" do
      skip "TODO add assertion against schema"
    end

    it "exports all necessary metadata" do
      expect(presenter.exportable_attributes).to include(
        content_id: "cont-ent-id",
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
      expect(presenter.exportable_attributes[:details][:related_discussion]).to eq(
        title: "Discussion Forum",
        href: "http://someforum.gov.uk"
      )
    end

    it "omits related_discusion when it's not provided" do
      edition.related_discussion_title = ''
      edition.related_discussion_href = ''
      expect(presenter.exportable_attributes[:details][:related_discussion]).to be_blank
    end

    it "includes h2 links for the sidebar" do
      edition.body = "## Header 1 \n\n### Subheader \n\n## Header 2\n\ntext"
      expect(presenter.exportable_attributes[:details][:header_links]).to match_array([
        { title: "Header 1", href: "#header-1" },
        { title: "Header 2", href: "#header-2" }
      ])
    end

    it "renders body to HTML" do
      edition.body = "__look at me__"
      expect(presenter.exportable_attributes[:details][:body]).to include("<strong>look at me</strong>")
    end

    it "exports the title" do
      edition.title = "Agile Process"
      expect(presenter.exportable_attributes[:title]).to eq("Agile Process")
    end
  end
end
