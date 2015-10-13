require 'rails_helper'
require 'capybara/rails'

RSpec.describe "creating guides", type: :feature do
  before do
    visit root_path
    click_link "Create a Guide"
  end

  it "stores guide metadata" do
    fill_in "Slug", with: "/the/path"
    fill_in "Title", with: "The Title"
    click_button "Publish"

    guide = Guide.first
    expect(guide.slug).to eq "/the/path"
  end

  it "saves draft guide editions" do
    fill_in "Slug", with: "/the/path"
    fill_in "Title", with: "First Draft"
    select "Design Community", from: "Published by"
    click_button "Save Draft"

    within ".main-alert" do
      expect(page).to have_content('created')
    end

    edition = Guide.first.latest_edition
    content_id = Guide.first.content_id
    expect(content_id).to be_present
    expect(edition.publisher_title).to eq "Design Community"
    expect(edition.title).to eq "First Draft"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false

    visit edit_guide_path(Guide.first)
    fill_in "Title", with: "Second Draft"
    click_button "Save Draft"

    within ".main-alert" do
      expect(page).to have_content('updated')
    end

    edition = Guide.first.latest_edition
    expect(Guide.first.content_id).to eq content_id
    expect(edition.title).to eq "Second Draft"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false
  end

  it "publishes guide editions" do
    fill_in "Slug", with: "/the/path"
    fill_in "Title", with: "First Published Edition"
    click_button "Publish"

    within ".main-alert" do
      expect(page).to have_content('created')
    end

    edition = Guide.first.latest_edition
    content_id = Guide.first.content_id
    expect(content_id).to be_present
    expect(edition.title).to eq "First Published Edition"
    expect(edition.draft?).to eq false
    expect(edition.published?).to eq true

    visit edit_guide_path(Guide.first)
    fill_in "Title", with: "Second Published Edition"
    click_button "Publish"

    within ".main-alert" do
      expect(page).to have_content('updated')
    end
    edition = Guide.first.latest_edition
    expect(Guide.first.content_id).to eq content_id
    expect(edition.title).to eq "Second Published Edition"
    expect(edition.draft?).to eq false
    expect(edition.published?).to eq true
  end
end
