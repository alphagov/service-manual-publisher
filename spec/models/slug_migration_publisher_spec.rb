require 'rails_helper'

RSpec.describe SlugMigrationPublisher, type: :model do
  it "publishes slug migrations" do
    edition = Generators.valid_published_edition
    guide = Guide.create!(slug: "/service-manual/new-path", latest_edition: edition)
    slug_migration = SlugMigration.create!(completed: true, slug: "/service-manual/some-jekyll-path.html", guide: guide)

    expected_redirect = {
      content_id: slug_migration.content_id,
      format: "redirect",
      publishing_app: "service-manual-publisher",
      base_path: slug_migration.slug,
      redirects: [
        {
          path: slug_migration.slug,
          type: "exact",
          destination: slug_migration.guide.slug,
        }
      ]
    }

    api_double = double(:publishing_api)
    expect(GdsApi::PublishingApiV2).to receive(:new).and_return(api_double)
    expect(api_double).to receive(:put_content)
      .with(an_instance_of(String), expected_redirect)
    expect(api_double).to receive(:publish)
      .once.with(slug_migration.content_id, 'minor')

    SlugMigrationPublisher.new.process(slug_migration)
  end

  it "publishes slug migrations that are valid" do
    edition = Generators.valid_published_edition
    guide = Guide.create!(slug: "/service-manual/new-path", latest_edition: edition)
    slug_migration = SlugMigration.create!(completed: true, slug: "/service-manual/some-jekyll-path.html", guide: guide)

    api_double = double(:publishing_api)
    expect(GdsApi::PublishingApiV2).to receive(:new).and_return(api_double)
    expect(api_double).to receive(:put_content)
      .with(an_instance_of(String), be_valid_against_schema('redirect'))
    expect(api_double).to receive(:publish)
      .once.with(slug_migration.content_id, 'minor')

    SlugMigrationPublisher.new.process(slug_migration)
  end
end
