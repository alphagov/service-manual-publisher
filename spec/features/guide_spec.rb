require 'rails_helper'
require 'capybara/rails'

RSpec.describe "creating guides", type: :feature do
  before do
    visit root_path
    click_link "Create a Guide"
  end

  it "stores guide metadata" do
    fill_in "Slug", with: "/the/path"
    click_button "Publish"

    guide = Guide.first
    expect(guide.slug).to eq "/the/path"
  end

  it "saves draft guide editions" do
    fill_in "Slug", with: "/the/path"
    fill_in "Title", with: "First Draft"
    click_button "Save Draft"
    within ".main-alert" do
      expect(page).to have_content('created')
    end
    expect(Guide.first.latest_edition.title).to eq "First Draft"
    expect(Guide.first.latest_edition.draft?).to eq true
    expect(Guide.first.latest_edition.published?).to eq false

    visit edit_guide_path(Guide.first)
    fill_in "Title", with: "Second Draft"
    click_button "Save Draft"
    within ".main-alert" do
      expect(page).to have_content('updated')
    end
    expect(Guide.first.latest_edition.title).to eq "Second Draft"
    expect(Guide.first.latest_edition.draft?).to eq true
    expect(Guide.first.latest_edition.published?).to eq false
  end

  it "publishes guide editions" do
    fill_in "Slug", with: "/the/path"
    fill_in "Title", with: "First Published Edition"
    click_button "Publish"
    within ".main-alert" do
      expect(page).to have_content('created')
    end
    expect(Guide.first.latest_edition.title).to eq "First Published Edition"
    expect(Guide.first.latest_edition.draft?).to eq false
    expect(Guide.first.latest_edition.published?).to eq true

    visit edit_guide_path(Guide.first)
    fill_in "Title", with: "Second Published Edition"
    click_button "Publish"
    within ".main-alert" do
      expect(page).to have_content('updated')
    end
    expect(Guide.first.latest_edition.title).to eq "Second Published Edition"
    expect(Guide.first.latest_edition.draft?).to eq false
    expect(Guide.first.latest_edition.published?).to eq true
  end
end
