require 'rails_helper'

RSpec.describe Guide do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      edition = Generators.valid_edition(title: "something", state: "published")
      guide = Guide.create!(slug: "/service-manual/slug", content_id: nil, latest_edition: edition)
      expect(guide.content_id).to be_present
    end
  end

  describe "validations" do
    it "doesn't allow slugs without /service-manual/ prefix" do
      edition = Generators.valid_published_edition(title: "something", state: "published")
      edition = Guide.new(slug: "/something", latest_edition: edition)
      edition.valid?
      expect(edition.errors.full_messages_for(:slug)).to eq ["Slug must be be prefixed with /service-manual/"]
    end
  end

  context "review and approval" do
    let :edition do
      edition = Generators.valid_edition
      allow(edition).to receive(:persisted?) { true }
      edition
    end

    let :guide do
      Guide.new(slug: "/service-manual/something", latest_edition: edition)
    end

    describe "#can_mark_as_approved?" do
      it "returns true when a review has been requested" do
        edition.state = "review_requested"
        edition.save!
        expect(guide.can_mark_as_approved?).to be true
      end

      it "returns false when there's no edition" do
        guide.latest_edition = nil
        expect(guide.can_mark_as_approved?).to be false
      end

      it "returns false when latest_edition has not been saved" do
        allow(edition).to receive(:persisted?) { false }
        expect(guide.can_mark_as_approved?).to be false
      end
    end

    describe "#can_request_review?" do
      it "returns true when a review can be requested" do
        expect(guide.can_request_review?).to be true
      end

      it "returns false when there's no edition" do
        guide.latest_edition = nil
        expect(guide.can_request_review?).to be false
      end

      it "returns false when latest_edition has not been saved" do
        allow(edition).to receive(:persisted?) { false }
        expect(guide.can_request_review?).to be false
      end

      it "returns false when a review has been requested" do
        edition.state = "review_requested"
        expect(guide.can_request_review?).to be false
      end

      it "returns false when a review has been published" do
        edition.state = "published"
        expect(guide.can_request_review?).to be false
      end

      it "returns false when a review has been approved" do
        edition.state = "approved"
        expect(guide.can_request_review?).to be false
      end
    end

  end

end
