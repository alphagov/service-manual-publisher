require 'rails_helper'

RSpec.describe SlugMigrationPublisher, type: :model do
  it "publishes slug migrations" do
    slug_migration = SlugMigration.create!(
      completed: true,
      slug: "/service-manual/some-jekyll-path.html",
      redirect_to: "/service-manual/something",
    )

    expected_redirect = {
      format: "redirect",
      publishing_app: "service-manual-publisher",
      base_path: slug_migration.slug,
      redirects: [
        {
          path: slug_migration.slug,
          type: "exact",
          destination: slug_migration.redirect_to,
        }
      ]
    }

    api_double = double(:publishing_api)
    expect(GdsApi::PublishingApiV2).to receive(:new).and_return(api_double)
    expect(api_double).to receive(:put_content)
      .with(slug_migration.content_id, expected_redirect)
    expect(api_double).to receive(:publish)
      .once.with(slug_migration.content_id, 'major')

    SlugMigrationPublisher.new.process(
      content_id: slug_migration.content_id,
      old_path:   slug_migration.slug,
      new_path:   slug_migration.redirect_to,
    )
  end

  it "publishes slug migrations that are valid" do
    slug_migration = SlugMigration.create!(
      completed: true,
      slug: "/service-manual/some-jekyll-path.html",
      redirect_to: "/service-manual/something",
    )

    api_double = double(:publishing_api)
    expect(GdsApi::PublishingApiV2).to receive(:new).and_return(api_double)
    expect(api_double).to receive(:put_content)
      .with(an_instance_of(String), be_valid_against_schema('redirect'))
    expect(api_double).to receive(:publish)
      .once.with(slug_migration.content_id, 'major')

    SlugMigrationPublisher.new.process(
      content_id: slug_migration.content_id,
      old_path:   slug_migration.slug,
      new_path:   slug_migration.redirect_to,
    )
  end
end
