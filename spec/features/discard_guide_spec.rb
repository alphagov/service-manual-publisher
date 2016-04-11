require 'rails_helper'
require 'capybara/rails'

RSpec.describe "discarding guides", type: :feature do
  let :publisher do
    double(:publisher)
  end

  context "guide that has been published" do
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

    it "restores it to the latest published edition" do
      visit edit_guide_path(guide)
      click_first_button "Discard draft"
      within ".alert" do
        expect(page).to have_content "Draft has been discarded"
      end
      expect(guide.reload.latest_edition.body).to eq "This is the published edition"
    end

    it "discards the draft in the publishing api" do
      expect(Publisher).to receive(:new).with(content_model: guide).and_return publisher
      expect(publisher).to receive(:discard_draft)

      visit edit_guide_path(guide)
      click_first_button "Discard draft"
    end
  end

  context "guide that has never been published" do
    let :guide do
      create(
        :guide,
        editions: [
          build(:draft_edition, body: "This is the first draft edition"),
        ],
      )
    end

    it "completely destroys it" do
      visit edit_guide_path(guide)
      click_first_button "Discard draft"
      within ".alert" do
        expect(page).to have_content "Guide has been discarded"
      end

      expect(Guide.where(id: guide.id).count).to be 0
    end

    it "discards the draft in the publishing api" do
      expect(Publisher).to receive(:new).with(content_model: guide).and_return publisher
      expect(publisher).to receive(:discard_draft)

      visit edit_guide_path(guide)
      click_first_button "Discard draft"
    end
  end
end
