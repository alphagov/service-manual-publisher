require 'rails_helper'

RSpec.describe EditionsHelper, "#event_action_for_changed_state", type: :helper do
  context "when draft" do
    it "describes the action" do
      expect(
        helper.event_action_for_changed_state("draft")
        ).to eq("Draft")
    end
  end

  context "when requesting a review" do
    it "describes the action" do
      expect(
        helper.event_action_for_changed_state("review_requested")
        ).to eq("Review requested")
    end
  end

  context "when ready" do
    it "describes the action" do
      expect(
        helper.event_action_for_changed_state("ready")
        ).to eq("Approved")
    end
  end

  context "when published" do
    it "describes the action" do
      expect(
        helper.event_action_for_changed_state("published")
        ).to eq("Published")
    end
  end
end
