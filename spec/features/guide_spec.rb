require 'rails_helper'
require 'capybara/rails'

RSpec.describe "creating guides", type: :feature do
  before do
    visit root_path
    click_link "Create a Guide"

    double_api = double(:publishing_api)
    GdsApi::PublishingApi.stub(:new).and_return(double_api)
    double_api.stub(:put_draft_content_item)
    double_api.stub(:put_content_item)
  end

  it "saves draft guide editions" do
    fill_in_guide_form

    click_button "Save Draft"

    within ".main-alert" do
      expect(page).to have_content('created')
    end

    guide = Guide.find_by_slug("/the/path")
    edition = guide.latest_edition
    content_id = guide.content_id
    expect(content_id).to be_present
    expect(edition.related_discussion_title).to eq "Discussion on HackPad"
    expect(edition.related_discussion_href).to eq "https://designpatterns.hackpad.com/"
    expect(edition.publisher_title).to eq "Design Community"
    expect(edition.phase).to eq "beta"
    expect(edition.title).to eq "First Edition Title"
    expect(edition.body).to eq "## First Edition Title"
    expect(edition.update_type).to eq "minor"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false

    visit edit_guide_path(guide)
    fill_in "Title", with: "Second Edition Title"
    click_button "Save Draft"

    within ".main-alert" do
      expect(page).to have_content('updated')
    end

    guide = Guide.find_by_slug("/the/path")
    edition = guide.latest_edition
    expect(guide.content_id).to eq content_id
    expect(edition.title).to eq "Second Edition Title"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false
  end

  it "publishes guide editions" do
    fill_in_guide_form

    click_button "Publish"

    within ".main-alert" do
      expect(page).to have_content('created')
    end

    guide = Guide.find_by_slug("/the/path")
    edition = guide.latest_edition
    expect(edition.title).to eq "First Edition Title"
    expect(edition.draft?).to eq false
    expect(edition.published?).to eq true

    visit edit_guide_path(guide)
    fill_in "Title", with: "Second Edition Title"
    click_button "Publish"

    within ".main-alert" do
      expect(page).to have_content('updated')
    end

    guide = Guide.find_by_slug("/the/path")
    edition = guide.latest_edition
    expect(edition.title).to eq "Second Edition Title"
    expect(edition.draft?).to eq false
    expect(edition.published?).to eq true
  end

private

  def fill_in_guide_form
    fill_in "Slug", with: "/the/path"
    fill_in "Related discussion title", with: "Discussion on HackPad"
    fill_in "Link to related discussion", with: "https://designpatterns.hackpad.com/"
    select "Design Community", from: "Published by"
    select "Beta", from: "Phase"
    fill_in "Description", with: "This guide acts as a test case"

    fill_in "Title", with: "First Edition Title"
    fill_in "Body", with: "## First Edition Title"

    select "Minor", from: "Update type"
  end
end
