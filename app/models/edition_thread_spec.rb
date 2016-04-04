require 'rails_helper'

RSpec.describe EditionThread, "#events" do
  describe "new draft event" do
    it "the first event is a 'new draft' event" do
      most_recent_edition = create(:edition, version: 1)

      event = described_class.new(most_recent_edition).events.first

      expect(event).to be_a(EditionThread::NewDraftEvent)
    end

    it "relates to the first edition in the thread" do
      first_edition = create(:edition, version: 1, created_at: 1.day.ago)
      most_recent_edition = create(:edition, version: 1)

      event = described_class.new(most_recent_edition).events.first

      expect(event.edition).to eq(first_edition)
    end
  end

  describe "assigned to event" do
    it "the second event is an 'assigned to' event" do
      most_recent_edition = create(:edition, version: 1)

      event = described_class.new(most_recent_edition).events.second

      expect(event).to be_a(EditionThread::AssignedToEvent)
    end

    it "relates to the first edition in the thread" do
      first_edition = create(:edition, version: 1, created_at: 1.day.ago)
      most_recent_edition = create(:edition, version: 1)

      event = described_class.new(most_recent_edition).events.second

      expect(event.edition).to eq(first_edition)
    end
  end

  describe "comment event" do
    it "is a 'comment' event" do
      most_recent_edition = create(:edition, version: 1)
      most_recent_edition.comments.create!(comment: "My words are gold")

      event = described_class.new(most_recent_edition).events.third

      expect(event).to be_a(EditionThread::CommentEvent)
    end

    it "has a reference to the comment" do
      most_recent_edition = create(:edition, version: 1)
      comment = most_recent_edition.comments.create!(comment: "My words are gold")

      event = described_class.new(most_recent_edition).events.third

      expect(event.comment).to eq(comment)
    end
  end
end
