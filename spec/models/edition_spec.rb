require 'rails_helper'

RSpec.describe Edition, type: :model do
  describe "#phase" do
    it "defaults to 'alpha'" do
      expect(Edition.new.phase).to eq 'alpha'
    end
  end

  describe "#previously_published_edition" do
    let(:e1) { Generators.valid_published_edition }
    let(:e2) { Generators.valid_published_edition }
    let(:e3) { Generators.valid_published_edition }
    let(:e4) { Generators.valid_published_edition }

    before { Guide.create!(slug: '/service-manual/test', editions: [e1, e2, e3, e4]) }

    it "returns an edition that was the latest edition published before the current one" do
      expect(e3.previously_published_edition).to eq e2
      expect(e4.previously_published_edition).to eq e3
    end

    it "returns nil if it has no prviously published editions" do
      expect(e1.previously_published_edition).to eq nil
    end
  end

  describe "validations" do
    it "requires user to be present" do
      edition = Generators.valid_edition(user: nil)
      expect(edition).to be_invalid
      expect(edition.errors.full_messages_for(:user).size).to eq 1
    end

    it "does not allow updating already published editions" do
      edition = Generators.valid_published_edition
      edition.save!

      edition.update_attributes(title: "Republishing")

      expect(edition.errors.full_messages_for(:base).size).to eq 1
    end

    describe "state" do
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

    describe "#can_be_approved?" do
      it "returns true when a review has been requested" do
        edition.state = "review_requested"
        edition.save!
        expect(edition.can_be_approved?).to be true
      end

      it "returns false when latest_edition has not been saved" do
        allow(edition).to receive(:persisted?) { false }
        expect(edition.can_be_approved?).to be false
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

      it "returns false when a review has been approved" do
        edition.state = "approved"
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

  describe "#change_note_html" do
    it "renders markdown" do
      edition = Edition.new(change_note: "# heading")
      expect(edition.change_note_html).to eq "<h1>heading</h1>\n"
    end

    it "auto links" do
      edition = Edition.new(change_note: "http://example.org")
      expect(edition.change_note_html).to eq "<p><a href=\"http://example.org\">http://example.org</a></p>\n"
    end
  end

  describe "#draft_copy" do
    it "builds a new draft object with all fields but change notes" do
      edition = Generators.valid_published_edition(title: "Original Title", change_note: "Changes")
      draft = edition.draft_copy

      expect(draft.title).to eq "Original Title"
      expect(draft).to be_new_record
      expect(draft).to be_a_draft
      expect(draft.change_note).to be_blank
    end
  end

  describe "#search" do
    it "has triggers setup" do
      expect(HairTrigger::migrations_current?).to be true
    end

    it "searches title" do
      titles = ["Standups", "Unit Testing"]
      titles.each_with_index do |title, index|
        edition = Generators.valid_edition(state: "review_requested", title: title)
        Guide.create!(latest_edition: edition, slug: "/service-manual/#{index}")
      end

      results = Edition.search("testing").map {|e| e.title}
      expect(results).to eq ["Unit Testing"]
    end

    it "prioritises title over body" do
      edition = Generators.valid_edition(state: "review_requested", title: "nothing", body: "search")
      Guide.create!(latest_edition: edition, slug: "/service-manual/1")

      edition = Generators.valid_edition(state: "review_requested", title: "search", body: "nothing")
      Guide.create!(latest_edition: edition, slug: "/service-manual/2")

      results = Edition.search("search").map {|e| e.title}
      expect(results).to eq ["search", "nothing"]
    end
  end
end
