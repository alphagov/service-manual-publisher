require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Commenting", type: :feature do
  it "allows discourse" do
    edition = Generators.valid_edition
    guide = Guide.create!(
      latest_edition: edition,
      slug: "/service-manual/test/slug_published"
    )

    visit edit_guide_path(guide)
    within ".comments" do
      fill_in "Comment", with: "This is my comment"
      click_button "Comment"
    end

    visit edit_guide_path(guide)
    within ".comments .comment" do
      expect(page).to have_content "Stub User"
      expect(page).to have_content "This is my comment"
    end
  end
end
