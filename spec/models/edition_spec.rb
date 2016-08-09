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

    it "requires a created_by user" do
      edition = build(:edition, created_by: nil)
      edition.valid?

      expect(
        edition.errors.full_messages_for(:created_by)
      ).to include("Created by can't be blank")
    end
  end

  context "review and approval" do
    let :edition do
      edition = build(:edition)
      allow(edition).to receive(:persisted?) { true }
      edition
    end

    let :guide do
      build(:guide, slug: "/service-manual/topic-name/something", editions: [edition])
    end

    describe "#can_be_approved?" do
      let :user do
        build(:user)
      end

      it "returns true when a review has been requested" do
        edition.state = "review_requested"
        edition.save!
        expect(edition.can_be_approved?(user)).to be true
      end

      it "returns false when the author is also the editor" do
        edition.state = "review_requested"
        edition.author = build(:user, name: "anotehr", email: "email@address.org")
        expect(edition.can_be_approved?(edition.author)).to eq false
      end

      it "returns true when the user is also the editor but the ALLOW_SELF_APPROVAL flag is set" do
        edition.state = "review_requested"
        edition.author = build(:user, name: "anotehr", email: "email@address.org")
        edition.save!
        ENV['ALLOW_SELF_APPROVAL'] = '1'
        expect(edition.can_be_approved?(edition.author)).to eq true
        ENV.delete('ALLOW_SELF_APPROVAL')
      end

      it "returns false when latest_edition has not been saved" do
        allow(edition).to receive(:persisted?) { false }
        expect(edition.can_be_approved?(user)).to be false
      end
    end

    describe "#can_request_review?" do
      it "returns true when a review can be requested" do
        expect(edition.can_request_review?).to be true
      end

      it "returns false when latest_edition has not been saved" do
        allow(edition).to receive(:persisted?) { false }
        expect(edition.can_request_review?).to be false
      end

      it "returns false when a review has been requested" do
        edition.state = "review_requested"
        expect(edition.can_request_review?).to be false
      end

      it "returns false when a review has been published" do
        edition.state = "published"
        expect(edition.can_request_review?).to be false
      end

      it "returns false when a review has been ready" do
        edition.state = "ready"
        expect(edition.can_request_review?).to be false
      end

      it "returns false when the edition is unpublished" do
        edition.state = "unpublished"
        expect(edition.can_request_review?).to be false
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

      it "returns false if it's not ready" do
        edition.state = "review_requested"
        expect(edition.can_be_published?).to be false
      end

      it "returns false if it's not the latest edition of a guide" do
        edition.state = "ready"
        guide.editions << edition.dup

        edition.guide.reload
        expect(edition.can_be_published?).to be false
      end

      it "returns true if it's the latest edition and is ready" do
        edition.state = "ready"
        expect(edition.can_be_published?).to be true
      end
    end

    describe "#can_discard_draft?" do
      it "returns true" do
        expect(edition.can_discard_draft?).to be true
      end

      it "returns false if not persisted" do
        expect(edition).to receive(:persisted?).and_return(false)
        expect(edition.can_discard_draft?).to be false
      end

      it "returns false if it is published" do
        edition.state = "published"
        expect(edition.can_discard_draft?).to be false
      end

      it "returns false if it is unpublished" do
        edition.state = "unpublished"
        expect(edition.can_discard_draft?).to be false
      end
    end
  end
end
