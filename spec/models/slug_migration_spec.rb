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
end
