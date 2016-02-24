require 'rails_helper'
require 'capybara/rails'

RSpec.describe "filtering guides", type: :feature do
  it "filters by state" do
    Guide.create!(
      slug: "/service-manual/a",
      latest_edition: Generators.valid_edition(state: "review_requested", title: "Edition 1"),
    )
    Guide.create!(
      slug: "/service-manual/b",
      latest_edition: Generators.valid_edition(state: "draft", title: "Edition 2"),
    )

    filter_by_state "Draft"
    expect(page).to_not have_text "Edition 1"
    expect(page).to have_text "Edition 2"

    filter_by_state "Review Requested"
    expect(page).to have_text "Edition 1"
    expect(page).to_not have_text "Edition 2"
  end

  it "filters by user" do
    dave = Generators.valid_user(name: "Dave")
    linda = Generators.valid_user(name: "Linda")
    Guide.create!(
      slug: "/service-manual/a",
      latest_edition: Generators.valid_edition(user: dave),
    )
    Guide.create!(
      slug: "/service-manual/b",
      latest_edition: Generators.valid_edition(user: linda),
    )

    filter_by_user "Dave"
    expect(page).to have_text "/service-manual/a"
    expect(page).to_not have_text "/service-manual/b"

    filter_by_user "Linda"
    expect(page).to_not have_text "/service-manual/a"
    expect(page).to have_text "/service-manual/b"
  end

  it "filters by published by" do
    [1, 2].each do |i|
      guide_community = Generators.valid_guide_community(
        latest_edition: Generators.valid_edition(content_owner: nil, title: "Content Owner #{i}")
        ).tap(&:save!)
      edition = Generators.valid_edition(
        state: "review_requested",
        title: "Edition #{i}",
        content_owner_id: guide_community.id,
      )
      Guide.create!(latest_edition: edition, slug: "/service-manual/#{i}")
    end

    filter_by_published_by "Content Owner 1"
    expect(page).to have_text "Edition 1"
    expect(page).to_not have_text "Edition 2"

    filter_by_published_by "Content Owner 2"
    expect(page).to_not have_text "Edition 1"
    expect(page).to have_text "Edition 2"
  end

  it "searches for keywords" do
    edition1 = Generators.valid_edition(state: "review_requested", title: "Standups")
    Guide.create!(latest_edition: edition1, slug: "/service-manual/something")

    edition2 = Generators.valid_edition(state: "review_requested", title: "Unit Testing")
    Guide.create!(latest_edition: edition2, slug: "/service-manual/something")

    search_for "testing"

    expect(page).to have_text "Unit Testing"
    expect(page).to_not have_text "Standups"
  end

  it "combines keywords with state filters" do
    edition1 = Generators.valid_edition(state: "draft", title: "Draft Standups")
    Guide.create!(latest_edition: edition1, slug: "/service-manual/something")

    edition2 = Generators.valid_edition(state: "review_requested", title: "Reviewed Standups")
    Guide.create!(latest_edition: edition2, slug: "/service-manual/something")

    visit root_path
    within ".filters" do
      fill_in "Title or slug", with: "standups"
      select "Draft", from: "State"
      click_button "Filter guides"
    end

    expect(page).to have_text "Draft Standups"
    expect(page).to_not have_text "Reviewed Standups"
  end

  it "displays a page header that's based on the query" do
    Generators.valid_guide_community(
        latest_edition: Generators.valid_edition(content_owner: nil, title: "Design Community")
        ).tap(&:save!)
    User.create!(name: "Ronan", email: "ronan@example.com")
    visit root_path
    within ".filters" do
      fill_in "Title or slug", with: "Form Design"
      select "Ronan", from: "User"
      select "Design Community", from: "Published by"
      select "Draft", from: "State"
      click_button "Filter guides"
    end

    expect(page).to have_text "Ronan's draft guides matching \"Form Design\" published by Design Community"
  end

  [:user, :state, :published_by].each do |n|
    define_method("filter_by_#{n}") do |value|
      visit root_path
      within ".filters" do
        select value, from: n.to_s.humanize
        click_button "Filter guides"
      end
    end
  end


  def search_for(q)
    visit root_path
    within ".filters" do
      fill_in "Title or slug", with: q
      click_button "Filter guides"
    end
  end
end
