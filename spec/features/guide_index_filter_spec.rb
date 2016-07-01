require 'rails_helper'
require 'capybara/rails'

RSpec.describe "filtering guides", type: :feature do
  it "filters by latest edition state" do
    create(
      :guide,
      editions: [
        build(:edition, state: "draft", title: "Edition that is not expected"),
        build(:edition, state: "review_requested", title: "Edition that is not expected"),
      ],
    )
    create(
      :guide,
      editions: [
        build(:edition, state: "draft", title: "Expected edition"),
      ],
    )

    filter_by_state "Draft"
    expect(page).to have_content "Expected edition"
    expect(page).to_not have_content "Edition that is not expected"
  end

  it "filters by user" do
    dave = build(:user, name: "Dave")
    linda = build(:user, name: "Linda")

    create(:guide,
           slug: "/service-manual/topic-name/a",
           editions: [build(:edition, author: dave)],
          )
    create(:guide,
           slug: "/service-manual/topic-name/b",
           editions: [build(:edition, author: linda)],
          )

    filter_by_author "Dave"
    expect(page).to have_text "/service-manual/topic-name/a"
    expect(page).to_not have_text "/service-manual/topic-name/b"

    filter_by_author "Linda"
    expect(page).to_not have_text "/service-manual/topic-name/a"
    expect(page).to have_text "/service-manual/topic-name/b"
  end

  it "filters by community" do
    [1, 2].each do |i|
      guide_community = create(:guide_community, :with_published_edition, title: "Content Owner #{i}")
      create(:guide, :with_review_requested_edition, edition: {
        title: "Edition #{i}",
        content_owner_id: guide_community.id
      })
    end

    filter_by_community "Content Owner 1"
    expect(page).to have_text "Edition 1"
    expect(page).to_not have_text "Edition 2"

    filter_by_community "Content Owner 2"
    expect(page).to_not have_text "Edition 1"
    expect(page).to have_text "Edition 2"
  end

  it "filters by page type" do
    guide_community_edition = build(:edition, content_owner: nil, title: "Agile Community")
    guide_community = create(:guide_community, editions: [guide_community_edition])

    edition = build(:edition, content_owner: guide_community, title: "Scrum")
    create(:guide, editions: [edition])

    visit root_path
    expect(page).to have_css(".guide-table td", text: "Agile Community")
    expect(page).to have_css(".guide-table td", text: "Scrum")

    filter_by_page_type "All"
    expect(page).to have_css(".guide-table td", text: "Agile Community")
    expect(page).to have_css(".guide-table td", text: "Scrum")

    filter_by_page_type "Guide Community"
    expect(page).to have_css(".guide-table td", text: "Agile Community")
    expect(page).to_not have_css(".guide-table td", text: "Scrum")

    filter_by_page_type "Guide"
    expect(page).to_not have_css(".guide-table td", text: "Agile Community")
    expect(page).to have_css(".guide-table td", text: "Scrum")
  end

  it "searches for keywords" do
    edition1 = build(:edition, state: "review_requested", title: "Standups")
    create(:guide, slug: "/service-manual/topic-name/something", editions: [edition1])

    edition2 = build(:edition, state: "review_requested", title: "Unit Testing")
    create(:guide, slug: "/service-manual/topic-name/something", editions: [edition2])

    search_for "testing"

    expect(page).to have_text "Unit Testing"
    expect(page).to_not have_text "Standups"
  end

  it "combines keywords with state filters" do
    draft_guide = create(:guide, title: "Hello World")
    review_requested_guide = create(:guide, :with_review_requested_edition, title: "Hello Earth")

    visit root_path

    expect(page).to have_text draft_guide.title
    expect(page).to have_text review_requested_guide.title

    within ".filters" do
      fill_in "Title or slug", with: "Hello"
      select "Draft", from: "State"
      click_button "Filter guides"
    end

    expect(page).to have_text draft_guide.title
    expect(page).to_not have_text review_requested_guide.title
  end

  it "displays a page header that's based on the query" do
    ronan = create(:user, name: "Ronan")
    guide_community = create(:guide_community, :with_published_edition, edition: { author: ronan })

    visit root_path
    within ".filters" do
      fill_in "Title or slug", with: "Form Design"
      select "Ronan", from: "Author"
      select guide_community.title, from: "Community"
      select "Draft", from: "State"
      click_button "Filter guides"
    end

    expect(page).to have_text "Ronan's draft guides matching \"Form Design\" published by #{guide_community.title}"
  end

  [:author, :state, :community, :page_type].each do |n|
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
