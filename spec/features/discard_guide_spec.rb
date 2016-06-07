require 'rails_helper'
require 'capybara/rails'

RSpec.describe "discarding guides", type: :feature do
  it "makes the user confirm discarding the draft", js: true do
    guide = create(:guide, :with_draft_edition)
    visit edit_guide_path(guide)
    click_first_button "Discard draft"
    expect(page.driver.browser.modal_message).to include "Are you sure you want to discard this draft?"
  end

  context "when the latest edition is published" do
    it "does not allow discarding" do
      guide = create(:published_guide)
      visit edit_guide_path(guide)
      expect(page).to_not have_button "Discard draft"
    end
  end

  context "with a successful discard_draft" do
    it "discards the draft in the publishing api" do
      guide = create(:guide, :with_draft_edition)

      expect(PUBLISHING_API).to receive(:discard_draft)

      visit edit_guide_path(guide)
      click_first_button "Discard draft"

      within ".alert" do
        expect(page).to have_content "Draft has been discarded"
      end
    end
  end

  context "with an unsuccessful discard_draft" do
    it "does not discard the draft" do
      guide = create(:guide, :with_draft_edition)

      api_error = GdsApi::HTTPClientError.new(
        422,
        "An error occurred",
        "error" => { "message" => "An error occurred" }
        )
      expect(PUBLISHING_API).to receive(:discard_draft).and_raise(api_error)

      visit edit_guide_path(guide)
      click_first_button "Discard draft"

      within ".alert" do
        expect(page).to have_content "An error occurred"
      end
    end
  end
end
