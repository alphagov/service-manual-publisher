require 'rails_helper'

RSpec.describe SlugMigration, type: :model do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      slug_migration = SlugMigration.create!(completed: false, slug: "/service-manual/some-jekyll-path.html")
      expect(slug_migration.content_id).to be_present
    end
  end

  it "is not completed by default" do
    migration = SlugMigration.create(slug: "/some/slug")
    expect(migration.completed).to eq false
  end

  it "has uniqueness validation on slug" do
    SlugMigration.create!(slug: "/something")

    migration = SlugMigration.new(slug: "/something")
    expect(migration.valid?).to eq false
    expect(migration.errors.full_messages_for(:slug).size).to eq 1
  end

  it "validates that guide has a published edition" do
    edition = Generators.valid_edition(state: "draft")
    guide = Guide.create!(slug: "/service-manual/slug", latest_edition: edition)

    migration = SlugMigration.new(slug: "/something", guide: guide)
    expect(migration.valid?).to eq false
    expect(migration.errors.full_messages_for(:guide).size).to eq 1
  end

  it "allows empty guides" do
    migration = SlugMigration.new(slug: "/something", guide: nil)
    expect(migration.valid?).to eq true
  end

  it "does not allow empty guides when migrating" do
    migration = SlugMigration.new(slug: "/something", guide: nil, completed: true)
    expect(migration.valid?).to eq false
    expect(migration.errors.full_messages_for(:guide).size).to eq 1
  end

  it "does not allow saving if it is already marked as completed" do
    edition = Generators.valid_published_edition
    guide = Guide.create!(slug: "/service-manual/slug", latest_edition: edition)
    migration = SlugMigration.create!(slug: "/something", guide: guide, completed: true)
    expect(migration.valid?).to eq false
    expect(migration.errors.full_messages_for(:base).size).to eq 1
  end
end
