require 'rails_helper'

RSpec.describe Edition, type: :model do
  describe "validations" do
    it "requires user to be present" do
      edition = Edition.new(user: nil)

      expect(edition).to be_invalid

      expect(edition.errors.full_messages_for(:user).size).to eq 1
    end

    it "allows 'draft' state" do
      edition = Edition.new(state: 'draft')

      edition.valid?

      expect(edition.errors.full_messages_for(:state).size).to eq 0
    end

    it "allows 'published' state" do
      edition = Edition.new(state: 'published')

      edition.valid?

      expect(edition.errors.full_messages_for(:state).size).to eq 0
    end

    it "does not allow arbitrary values" do
      edition = Edition.new(state: 'supercharged')

      edition.valid?

      expect(edition.errors.full_messages_for(:state).size).to eq 1
    end
  end
end
