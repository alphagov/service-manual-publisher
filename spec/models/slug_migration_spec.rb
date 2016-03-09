require 'rails_helper'

RSpec.describe SlugMigration, type: :model do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      slug_migration = SlugMigration.create!(
        completed: false,
        slug: "/service-manual/some-jekyll-path.html",
        redirect_to: "/some-path",
      )
      expect(slug_migration.content_id).to be_present
    end
  end

  it "is not completed by default" do
    migration = SlugMigration.create(slug: "/some/slug", redirect_to: "/some-path")
    expect(migration.completed).to eq false
  end

  it "has uniqueness validation on slug" do
    SlugMigration.create!(slug: "/something", redirect_to: "/some-path")
    migration = SlugMigration.new(slug: "/something", redirect_to: "/some-other-path")
    expect(migration.valid?).to eq false
    expect(migration.errors.full_messages_for(:slug).size).to eq 1
  end

  it "validates redirect_to is present" do
    migration = SlugMigration.new(slug: "/something", redirect_to: nil, completed: true)
    expect(migration.valid?).to eq false
    expect(migration.errors.full_messages_for(:redirect_to).size).to eq 1
  end

  it "does not allow saving if it is completed" do
    migration = SlugMigration.create!(slug: "/something", redirect_to: "/some-path", completed: true)
    expect(migration.valid?).to eq false
    expect(migration.errors.full_messages_for(:base).size).to eq 1
  end

  it "does not allow redirecting to the same path" do
    migration = build(
      :slug_migration,
      slug: "/service-manual/old-path",
      redirect_to: "/service-manual/old-path",
    )
    expect(migration).to_not be_valid
    expect(migration.errors.full_messages_for(:redirect_to).size).to eq 1
  end
end
