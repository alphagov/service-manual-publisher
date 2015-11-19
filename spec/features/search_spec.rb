require 'rails_helper'
require 'capybara/rails'

RSpec.describe "searching guides", type: :feature do
  it "searches for editions" do
    edition1 = Generators.valid_edition(state: "review_requested", title: "Standups")
    Guide.create!(latest_edition: edition1, slug: "/service-manual/something")

    edition2 = Generators.valid_edition(state: "review_requested", title: "Unit Testing")
    Guide.create!(latest_edition: edition2, slug: "/service-manual/something")

    search_for "testing"

    expect(page).to have_text "Unit Testing"
    expect(page).to_not have_text "Standups"
  end

  it "prioritises title over body" do
    edition = Generators.valid_edition(state: "review_requested", title: "nothing", body: "search")
    Guide.create!(latest_edition: edition, slug: "/service-manual/1")

    edition = Generators.valid_edition(state: "review_requested", title: "search", body: "nothing")
    Guide.create!(latest_edition: edition, slug: "/service-manual/2")

    search_for "search"

    results = all("tr").map{|tr| tr.all("td")[0].try(:text)}.compact
    expect(results).to eq ["search /service-manual/2", "nothing /service-manual/1"]
  end

  def search_for(q)
    visit root_path
    within ".search" do
      fill_in "Search", with: q
      click_button "Search"
    end
  end
end
