require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Commenting", type: :feature do
  let!(:guide) do
    edition = Generators.valid_edition
    Guide.create!(
      latest_edition: edition,
      slug: "/service-manual/test/comment"
    )
  end

  it "allows discourse" do
    visit root_path
    click_link "Edit"
    click_link "Comments and history"

    within ".comments" do
      fill_in "Add new comment", with: "This is my comment"
      click_button "Save comment"
    end

    expect(page.current_path).to eq edition_comments_path(guide.latest_edition)

    within ".comments .comment" do
      expect(page).to have_content "Stub User"
      expect(page).to have_content "This is my comment"
    end
  end
end
