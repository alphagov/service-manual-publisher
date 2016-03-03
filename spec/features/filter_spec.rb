require 'rails_helper'
require 'capybara/rails'

RSpec.describe "filtering guides", type: :feature do
  it "filters by state" do
    create(:guide,
          slug: "/service-manual/a",
          latest_edition: build(:edition, state:"review_requested", title: "Edition 1"),
         )
    create(:guide,
          slug: "/service-manual/b",
          latest_edition: build(:edition, state: "draft", title: "Edition 2"),
    )

    filter_by_state "Draft"
    expect(page).to_not have_text "Edition 1"
    expect(page).to have_text "Edition 2"

    filter_by_state "Review Requested"
    expect(page).to have_text "Edition 1"
    expect(page).to_not have_text "Edition 2"
  end

  it "filters by user" do
    dave = build(:user, name: "Dave")
    linda = build(:user, name: "Linda")

    create(:guide,
           slug: "/service-manual/a",
           latest_edition: build(:edition, user: dave),
    )
    create(:guide,
           slug: "/service-manual/b",
           latest_edition: build(:edition, user: linda),
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
      edition = build(:edition, content_owner: nil, title: "Content Owner #{i}")
      guide_community = create(:guide_community, latest_edition: edition)

      edition = build(:edition,
                      state: "review_requested",
                      title: "Edition #{i}",
                      content_owner_id: guide_community.id,
      )
      create(:guide, slug: "/service-manual/#{i}", latest_edition: edition)
    end

    filter_by_published_by "Content Owner 1"
    expect(page).to have_text "Edition 1"
    expect(page).to_not have_text "Edition 2"

    filter_by_published_by "Content Owner 2"
    expect(page).to_not have_text "Edition 1"
    expect(page).to have_text "Edition 2"
  end

  it "searches for keywords" do
    edition1 = build(:edition, state: "review_requested", title: "Standups")
    create(:guide, slug: "/service-manual/something", latest_edition: edition1)

    edition2 = build(:edition, state: "review_requested", title: "Unit Testing")
    create(:guide, slug: "/service-manual/something", latest_edition: edition2)

    search_for "testing"

    expect(page).to have_text "Unit Testing"
    expect(page).to_not have_text "Standups"
  end

  it "combines keywords with state filters" do
    draft_guide = create(:draft_guide)
    review_requested_guide = create(:review_requested_guide)

    visit root_path

    expect(page).to have_text draft_guide.title
    expect(page).to have_text review_requested_guide.title

    within ".filters" do
      fill_in "Title or slug", with: "draft"
      select "Draft", from: "State"
      click_button "Filter guides"
    end

    expect(page).to have_text draft_guide.title
    expect(page).to_not have_text review_requested_guide.title
  end

  it "displays a page header that's based on the query" do
    guide_community = create(:guide_community)

    create(:user, name: "Ronan")
    visit root_path
    within ".filters" do
      fill_in "Title or slug", with: "Form Design"
      select "Ronan", from: "User"
      select guide_community.title, from: "Published by"
      select "Draft", from: "State"
      click_button "Filter guides"
    end

    expect(page).to have_text "Ronan's draft guides matching \"Form Design\" published by #{guide_community.title}"
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
