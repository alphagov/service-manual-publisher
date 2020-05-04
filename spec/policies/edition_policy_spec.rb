require "rails_helper"

RSpec.describe EditionPolicy do
  let(:author_a) { build_stubbed(:user) }
  let(:author_b) { build_stubbed(:user) }

  describe "#can_be_approved?" do
    it "is true after a review is requested and attempted by a different author" do
      edition = build_stubbed(:edition, state: "review_requested", author: author_a)

      expect(
        described_class.new(author_b, edition).can_be_approved?,
      ).to eq(true)
    end

    it "is true when the edition after a review is requested and the ALLOW_SELF_APPROVAL is set" do
      edition = build_stubbed(:edition, state: "review_requested", author: author_a)
      allow(ENV).to receive(:[]).with("ALLOW_SELF_APPROVAL").and_return("1")

      expect(
        described_class.new(author_a, edition).can_be_approved?,
      ).to eq(true)
    end

    it "is false when attempted by the same author" do
      edition = build_stubbed(:edition, state: "review_requested", author: author_a)

      expect(
        described_class.new(author_a, edition).can_be_approved?,
      ).to eq(false)
    end

    (Edition::STATES - %w[review_requested]).each do |state|
      it "is false when the edition has a state of #{state}" do
        edition = build_stubbed(:edition, state: state, author: author_a)

        expect(
          described_class.new(author_b, edition).can_be_approved?,
        ).to eq(false)
      end
    end
  end

  describe "#can_request_review?" do
    it "is true if persisted and in a draft state" do
      edition = build_stubbed(:edition, state: "draft", author: author_a)

      expect(
        described_class.new(author_b, edition).can_request_review?,
      ).to eq(true)
    end

    it "is false if a new record" do
      edition = build(:edition, state: "draft", author: author_a)

      expect(
        described_class.new(author_b, edition).can_request_review?,
      ).to eq(false)
    end

    (Edition::STATES - %w[draft]).each do |state|
      it "is false when the edition has a state of #{state}" do
        edition = build_stubbed(:edition, state: state, author: author_a)

        expect(
          described_class.new(author_b, edition).can_request_review?,
        ).to eq(false)
      end
    end
  end

  describe "#can_be_published?" do
    it "is true if in a ready state and the latest edition" do
      edition = build(:edition, state: "ready", author: author_a)
      create(:guide, editions: [edition])

      expect(
        described_class.new(author_b, edition).can_be_published?,
      ).to eq(true)
    end

    it "is false if not the latest edition" do
      old_edition = build(:edition, state: "ready", created_at: 2.days.ago, author: author_a)
      new_edition = build(:edition, state: "ready", created_at: 1.days.ago, author: author_a)
      create(:guide, editions: [old_edition, new_edition])

      expect(
        described_class.new(author_b, old_edition).can_be_published?,
      ).to eq(false)
    end

    (Edition::STATES - %w[ready]).each do |state|
      it "is false when the edition has a state of #{state}" do
        edition = build(:edition, state: state, author: author_a)
        create(:guide, editions: [edition])

        expect(
          described_class.new(author_b, edition).can_be_published?,
        ).to eq(false)
      end
    end
  end

  describe "#can_discard_draft?" do
    undiscardable_states = %w[published unpublished]

    (Edition::STATES - undiscardable_states).each do |state|
      it "is true when the edition has a state of #{state}" do
        edition = build_stubbed(:edition, state: state, author: author_a)

        expect(
          described_class.new(author_b, edition).can_discard_draft?,
        ).to eq(true)
      end
    end

    undiscardable_states.each do |state|
      it "is false when the edition has a state of #{state}" do
        edition = build_stubbed(:edition, state: state, author: author_a)

        expect(
          described_class.new(author_b, edition).can_discard_draft?,
        ).to eq(false)
      end
    end
  end

  describe "#can_preview?" do
    it "is true if persisted" do
      edition = build_stubbed(:edition, state: "draft", author: author_a)

      expect(
        described_class.new(author_b, edition).can_preview?,
      ).to eq(true)
    end

    it "is false if not persisted" do
      edition = build(:edition, state: "draft", author: author_a)

      expect(
        described_class.new(author_b, edition).can_preview?,
      ).to eq(false)
    end
  end

  describe "#can_discard_new_draft?" do
    it "is false if persisted" do
      edition = build_stubbed(:edition, state: "draft", author: author_a)

      expect(
        described_class.new(author_b, edition).can_discard_new_draft?,
      ).to eq(false)
    end

    it "is true if not persisted" do
      edition = build(:edition, state: "draft", author: author_a)

      expect(
        described_class.new(author_b, edition).can_discard_new_draft?,
      ).to eq(true)
    end
  end
end
