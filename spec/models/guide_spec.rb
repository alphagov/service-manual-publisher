require 'rails_helper'

RSpec.describe Guide do
  def valid_edition(attributes = {})
    attributes = {
      title:           "The Title",
      state:           "draft",
      phase:           "beta",
      description:     "Description",
      update_type:     "major",
      body:            "# Heading",
      publisher_title: "Publisher Name"
    }.merge(attributes)

    Edition.new(attributes)
  end

  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      edition = valid_edition(title: "something", state: "published")
      guide = Guide.create!(slug: "/slug", content_id: nil, editions: [edition])
      expect(guide.content_id).to be_present
    end
  end

  it "saves published items" do
    edition = valid_edition(title: "something", state: "published")
    edition.title = "Test Title"
    edition.body = "## Heading 1\n\n## Heading 2\n"
    edition.created_at = Time.now

    guide = Guide.new(editions: [edition])
    guide.slug = "/test/slug"
    allow(guide).to receive(:latest_edition).and_return edition

    double_api = double(:publishing_api)
    expected_plek = Plek.new.find('publishing-api')
    expect(GdsApi::PublishingApi).to receive(:new).with(expected_plek).and_return(double_api)

    expected_hash = {
      publishing_app:    "service-manual-publisher",
      rendering_app:     "government-frontend",
      public_updated_at: edition.created_at,
      routes:            [{ type: "exact", path: guide.slug }],
      format:            "service_manual_guide",
      title:             edition.title,
      update_type:       "minor",
      details:           {
        body:         "<h2 id=\"heading-1\">Heading 1</h2>\n\n<h2 id=\"heading-2\">Heading 2</h2>\n",
        header_links: [
          {:title=>"Heading 1", :href=>"#heading-1"},
          {:title=>"Heading 2", :href=>"#heading-2"},
        ],
      },
    }

    expect(double_api).to receive(:put_content_item).with(guide.slug, expected_hash)
    guide.save!
  end

  it "saves draft items" do
    edition = valid_edition(title: "something", state: "draft")
    edition.title = "Test Title"
    edition.body = "# Heading"
    edition.created_at = Time.now

    guide = Guide.new(editions: [edition])
    guide.slug = "/test/slug"
    allow(guide).to receive(:latest_edition).and_return edition

    double_api = double(:publishing_api)

    expected_plek = Plek.new.find('publishing-api')
    expect(GdsApi::PublishingApi).to receive(:new).with(expected_plek).and_return(double_api)

    expected_hash = {
      publishing_app:    "service-manual-publisher",
      rendering_app:     "government-frontend",
      public_updated_at: edition.created_at,
      routes:            [{ type: "exact", path: guide.slug }],
      format:            "service_manual_guide",
      title:             edition.title,
      update_type:       "minor",
      details:           {
        body: "<h1 id=\"heading\">Heading</h1>\n",
        header_links: [],
      },
    }

    expect(double_api).to receive(:put_draft_content_item).with(guide.slug, expected_hash)
    guide.save!
  end
end
