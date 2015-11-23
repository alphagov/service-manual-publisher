require 'rails_helper'
require 'capybara/rails'

RSpec.describe "filtering guides", type: :feature do
  it "filters by state" do
    edition1 = Generators.valid_edition(state: "review_requested", title: "Edition 1")
    Guide.create!(latest_edition: edition1, slug: "/service-manual/a")

    edition2 = Generators.valid_edition(state: "draft", title: "Edition 2")
    Guide.create!(latest_edition: edition2, slug: "/service-manual/b")

    visit root_path

    within ".filter-list" do
      click_link "Draft"
    end
    expect(page).to_not have_text "Edition 1"
    expect(page).to have_text "Edition 2"

    within ".filter-list" do
      click_link "Review Requested"
    end
    expect(page).to have_text "Edition 1"
    expect(page).to_not have_text "Edition 2"
  end
end
