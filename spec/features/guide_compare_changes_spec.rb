require "rails_helper"

RSpec.describe "Guide compare changes", type: :feature do
  before do
    publishing_api = double(:publishing_api)
    stub_const("PUBLISHING_API", publishing_api)
    allow(publishing_api).to receive(:put_content)
    allow(publishing_api).to receive(:patch_links)
  end

  [:guide, :guide_community].each do |guide_type|
    it "shows exact changes in any fields" do
      guide = create(guide_type, :with_published_edition, title: "First version", body: "### Hello")

      visit edit_guide_path(guide)
      fill_in "Title", with: "Second version"
      fill_in "Body", with: "## Hi"
      fill_in "Public change note", with: "Better greeting"
      click_first_button "Save"
      click_link "Compare changes"

      within ".title del" do
        expect(page).to have_content("First version")
      end

      within ".title ins" do
        expect(page).to have_content("Second version")
      end

      within ".body del" do
        expect(page).to have_content("### Hello")
      end

      within ".body ins" do
        expect(page).to have_content("## Hi")
      end
    end
  end

  [:guide, :guide_community].each do |_guide_type|
    it "shows all fields as additions if there are no previous editions" do
      guide = create(:guide, :with_draft_edition)
      visit edition_changes_path(new_edition_id: guide.latest_edition.id)

      within ".title ins" do
        expect(page).to have_content(guide.latest_edition.title)
      end

      within ".body ins" do
        expect(page).to have_content(guide.latest_edition.body)
      end
    end
  end
end
