require 'rails_helper'
require 'capybara/rails'

RSpec.describe "discarding guides", type: :feature do
  let :guide do
    create(
      :guide,
      editions: [
        build(:draft_edition, body: "This is the first draft edition"),
        build(:published_edition, body: "This is the published edition"),
        build(:draft_edition, body: "This is the latest draft edition"),
      ],
    )
  end

  context "with a successful discard_draft" do
    it "discards the draft in the publishing api" do
      publisher = double(:publisher)
      expect(Publisher).to receive(:new).with(content_model: guide).and_return publisher
      expect(publisher).to receive(:discard_draft)
        .and_return(Publisher::DiscardDraftResponse.new(success: true))

      visit edit_guide_path(guide)
      click_first_button "Discard draft"
      within ".alert" do
        expect(page).to have_content "Draft has been discarded"
      end
    end
  end

  context "with an unsuccessful discard_draft" do
    it "does not discard the draft" do
      discard_draft_response = Publisher::DiscardDraftResponse.new(
        success: false,
        errors: "An error occurred",
      )
      expect_any_instance_of(Publisher).to receive(:discard_draft)
        .and_return(discard_draft_response)

      visit edit_guide_path(guide)
      click_first_button "Discard draft"
      within ".alert" do
        expect(page).to have_content "An error occurred"
      end
    end
  end
end
