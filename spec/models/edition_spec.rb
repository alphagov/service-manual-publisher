require 'rails_helper'

RSpec.describe Edition, type: :model do
  describe ".unpublished" do
    it "returns unpublished editions" do
      create(:edition, state: 'draft')
      unpublished_edition = create(:edition, state: 'unpublished')

      expect(described_class.unpublished).to match_array([unpublished_edition])
    end
  end

  describe "#notification_subscribers" do
    let(:joe) { build(:user, name: "Joe") }
    let(:liz) { build(:user, name: "Liz") }

    it "is the edition author and the current edition author" do
      first_edition = build(:edition, author: joe, created_at: 1.week.ago)
      last_edition = build(:edition, author: liz, created_at: 1.day.ago)

      create(:guide, editions: [
        first_edition,
        last_edition,
      ])

      expect(first_edition.reload.notification_subscribers).to match_array [joe, liz]
    end

    it "avoids duplicates" do
      first = build(:edition, author: joe, created_at: 1.week.ago)
      second = build(:edition, author: joe, created_at: 1.day.ago)
      guide = create(:guide, editions: [first, second])

      expect(guide.latest_edition.notification_subscribers).to match_array [joe]
    end
  end

  describe "#phase" do
    it "defaults to 'beta'" do
      expect(Edition.new.phase).to eq 'beta'
    end
  end

  describe "#previously_published_edition" do
    let :editions do
      1.upto(4).map { build(:edition, :published) }
    end

    before do
      create(:guide, :with_published_edition, editions: editions)
    end

    it "returns an edition that was the latest edition published before the current one" do
      expect(editions[2].previously_published_edition).to eq editions[1]
      expect(editions[3].previously_published_edition).to eq editions[2]
    end

    it "returns nil if it has no previously published editions" do
      expect(editions[0].previously_published_edition).to eq nil
    end
  end

  describe "validations" do
    it "requires author to be present" do
      edition = build(:edition, author: nil)
      expect(edition).to be_invalid
      expect(edition.errors.full_messages_for(:author).size).to eq 1
    end

    it "requires version to be present" do
      edition = build(:edition, version: nil)
      expect(edition).to be_invalid
      expect(edition.errors.full_messages_for(:version).size).to eq 1
    end

    it "does not allow a new draft for a version that has been published" do
      guide = create(:guide, :with_published_edition)
      edition = Edition.new(guide: guide, state: 'draft', version: 1)

      expect(edition).to be_invalid
      expect(edition.errors[:version]).to include('has already been published')
    end

    describe "state" do
      it "allows 'published' state" do
        edition = build(:edition, :published)
        edition.valid?
        expect(edition.errors.full_messages_for(:state).size).to eq 0
      end

      valid_states = %w(draft review_requested ready)
      valid_states.each do |valid_state|
        it "allows '#{valid_state}' state" do
          edition = build(:edition, state: valid_state)
          edition.valid?
          expect(edition.errors.full_messages_for(:state).size).to eq 0
        end
      end

      it "does not allow arbitrary values" do
        edition = build(:edition, state: "invalid state")
        edition.valid?
        expect(edition.errors.full_messages_for(:state).size).to eq 1
      end
    end

    describe 'change_note' do
      it "is not allowed to be empty when the update_type is 'major'" do
        edition = build(:edition, update_type: "major", change_note: "")
        edition.valid?
        expect(edition.errors.full_messages_for(:change_note)).to eq ["Change note can't be blank"]
      end

      it "is allowed to be empty if the update_type is 'minor'" do
        edition = build(:edition, update_type: "minor", change_note: "")
        edition.valid?
        expect(edition.errors.full_messages_for(:change_note)).to be_empty
      end
    end

    describe "reason_for_change" do
      it "is allowed to be empty if the update_type is 'major' and it is the first version" do
        edition = build(:edition, update_type: "major", reason_for_change: "")
        edition.valid?
        expect(edition.errors.full_messages_for(:reason_for_change)).to be_empty
      end

      it "is not allowed to be empty if the update_type is 'major' and it is not the first version" do
        edition = build(:edition, update_type: "major", reason_for_change: "", version: 2)
        edition.valid?
        expect(edition.errors.full_messages_for(:reason_for_change)).to eq ["Reason for change can't be blank"]
      end

      it "is allowed to be empty if the update_type is 'minor'" do
        edition = build(:edition, update_type: "minor", reason_for_change: "")
        edition.valid?
        expect(edition.errors.full_messages_for(:reason_for_change)).to be_empty
      end
    end

    describe "update_type" do
      it "cannot be minor for the first edition" do
        edition = build(:edition, update_type: "minor", reason_for_change: "")
        edition.valid?
        expect(edition.errors.full_messages_for(:update_type)).to include 'Update type must be major'
      end
    end

    it "requires a created_by user" do
      edition = build(:edition, created_by: nil)
      edition.valid?

      expect(
        edition.errors.full_messages_for(:created_by)
      ).to include("Created by can't be blank")
    end
  end
end
