require 'rails_helper'

RSpec.describe "Guide integrity", type: :feature do
  context "when saving a draft if the guide has changed since the user started editing" do
    it "displays an error" do
      guide = create(:guide)
      visit edit_guide_path(guide)

      change_something_about_the_guide(guide)

      fill_in "Description", with: "This is an altered description"
      click_first_button "Save"

      within ".alert" do
        expect(page).to have_content("The guide has changed since you started editing")
      end
    end

    it "preserves the user's data in the form so they can decide what to do" do
      guide = create(:guide)
      visit edit_guide_path(guide)

      change_something_about_the_guide(guide)

      fill_in "Description", with: "This is an altered description"
      click_first_button "Save"

      expect(page).to have_field("Description", with: "This is an altered description")
    end

    def change_something_about_the_guide(guide)
      other_user = create(:user)
      extra_edition = guide.latest_edition.dup
      extra_edition.assign_attributes(created_by: other_user, state: 'review_requested')
      guide.editions << extra_edition
      expect(guide.reload.latest_edition.state).to eq('review_requested')
    end
  end

  context "when managing a guide's state if the guide has changed since the user started editing" do
    it "displays an error" do
      guide = create(:guide, :with_review_requested_edition)
      visit edit_guide_path(guide)

      other_user = create(:user)
      extra_edition = guide.latest_edition.dup
      extra_edition.assign_attributes(created_by: other_user, state: 'ready')
      guide.editions << extra_edition
      expect(guide.reload.latest_edition.state).to eq('ready')

      click_first_button 'Approve'

      within ".alert" do
        expect(page).to have_content("The guide has changed since you started editing")
      end
    end
  end
end
