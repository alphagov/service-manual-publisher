require 'rails_helper'

RSpec.describe Edition, type: :model do
  describe "validations" do
    it "requires user to be present" do
      edition = Generators.valid_edition(user: nil)
      expect(edition).to be_invalid
      expect(edition.errors.full_messages_for(:user).size).to eq 1
    end

    it "allows 'published' state" do
      edition = Generators.valid_published_edition
      edition.valid?
      expect(edition.errors.full_messages_for(:state).size).to eq 0
    end

    valid_states = %w(draft review_requested approved)
    valid_states.each do |valid_state|
      it "allows '#{valid_state}' state" do
        edition = Generators.valid_edition(state: valid_state)
        edition.valid?
        expect(edition.errors.full_messages_for(:state).size).to eq 0
      end
    end

    it "does not allow arbitrary values" do
      edition = Generators.valid_edition(state: 'invalid state')
      edition.valid?
      expect(edition.errors.full_messages_for(:state).size).to eq 1
    end

    it "does not allow empty change_note when the update_type is 'major'" do
      edition = Generators.valid_edition(update_type: "major", change_note: "")
      edition.valid?
      expect(edition.errors.full_messages_for(:change_note)).to eq ["Change note can't be blank"]
    end

    it "allows empty change_note when the update_type is 'minor'" do
      edition = Generators.valid_edition(update_type: "minor", change_note: "")
      edition.valid?
      expect(edition.errors.full_messages_for(:change_note).size).to eq 0
    end
  end

    describe "#can_be_published?" do
      before do
        guide.save!
      end

      it "returns false if it's already published" do
        edition.state = "published"
        expect(edition.can_be_published?).to be false
      end

      it "returns false if it's not approved" do
        edition.state = "review_requested"
        expect(edition.can_be_published?).to be false
      end

      it "returns false if it's not the latest edition of a guide" do
        edition.state = "approved"
        guide.editions << edition.dup
        expect(edition.can_be_published?).to be false
      end

      it "returns true if it's the latest edition and is approved" do
        edition.state = "approved"
        expect(edition.can_be_published?).to be true
      end
    end
  end
end
