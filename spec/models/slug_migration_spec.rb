require 'rails_helper'

RSpec.describe SlugMigration, type: :model do
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
end
