require "rails_helper"

RSpec.describe SlugMigration, type: :model do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      uuid = "1234-5678"
      expect(SecureRandom).to receive(:uuid).and_return uuid

      migration = create(
        :slug_migration,
        :with_redirect_to,
      )
      expect(migration.content_id).to eq uuid
    end
  end

  it "is not completed by default" do
    migration = create(
      :slug_migration,
      :with_redirect_to,
    )
    expect(migration.completed).to eq false
  end

  it "has uniqueness validation on slug" do
    create(:slug_migration, :with_redirect_to)
    migration = build(:slug_migration)
    expect(migration.valid?).to eq false
    expect(migration.errors.full_messages_for(:slug).size).to eq 1
  end

  it "validates redirect_to is present" do
    migration = build(
      :slug_migration,
      :completed,
      redirect_to: nil,
    )
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
