require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Taking a guide through the publishing process", type: :feature do

  before do
    allow_any_instance_of(GuidePublisher).to receive(:process)
  end

  it "should create a new edition if there are no drafts" do
    guide = given_a_guide_exists state: 'published'
    visit guides_path
    link = there_should_be_a_control_link "Create new edition", document: guide
    link.click
    the_form_should_be_prepopulated
    fill_in "Title", with: "Sample Published Edition 2"
    click_button "Save Draft"
    expect(current_path).to eq root_path

    expect(guide.editions.published.size).to eq 1
    expect(guide.editions.draft.size).to eq 1
    expect(guide.editions.map(&:title)).to match_array ["Sample Published Edition", "Sample Published Edition 2"]
  end

  it "should create a new edition even when saving a draft" do
    guide = given_a_guide_exists state: 'draft'
    visit guides_path
    link = there_should_be_a_control_link "Continue editing", document: guide
    link.click
    fill_in "Title", with: "Sample Published Edition 2"
    click_button "Save Draft"
    expect(current_path).to eq root_path

    expect(guide.editions.draft.size).to eq 2
    expect(guide.editions.map(&:title)).to match_array ["Sample Published Edition", "Sample Published Edition 2"]
  end

  it "should create a new edition when publishing a draft" do
    guide = given_a_guide_exists state: 'draft'
    visit guides_path
    link = there_should_be_a_control_link "Continue editing", document: guide
    link.click
    fill_in "Title", with: "Sample Published Edition 2"
    click_button "Publish"
    expect(current_path).to eq root_path

    expect(guide.editions.published.size).to eq 1
    expect(guide.editions.draft.size).to eq 1
    expect(guide.editions.map(&:title)).to match_array ["Sample Published Edition", "Sample Published Edition 2"]
  end

  it "should record who's the last editor" do
    stub_user.update_attribute :name, "John Smith"
    guide = given_a_guide_exists state: 'draft'
    visit edit_guide_path(guide)
    fill_in "Title", with: "An amended title"
    click_button "Save Draft"
    visit guides_path
    within ".last-edited-by" do
      expect(page).to have_content "John Smith"
    end
  end

  context "with a review request" do
    it "lists guides that need a review" do
      guide = given_a_guide_exists(state: 'draft')
      visit edit_guide_path(guide)
      click_button "Request a Review"
      visit guides_path
      expect(page).to have_content "Needs Review"
    end

    it "allows other users to approve it"
  end

  context "without a review request" do
    it "does not list guides that don't need a review" do
      given_a_guide_exists(state: 'draft')
      visit guides_path
      expect(page).to_not have_content "Needs Review"
    end
  end

  context "without any approvals" do
    it "does not allow guides to be published"
  end

  context "with approvals" do
    it "allows guides to be published"
  end

private

  def given_a_guide_exists(state:, user: nil)
    edition = Generators.valid_edition
    edition.state = state
    edition.title = 'Sample Published Edition'
    edition.user = user unless user.nil?
    Guide.create!(latest_edition: edition, slug: "/service-manual/test/slug_published")
  end

  def there_should_be_a_control_link(link_text, document:)
    link = find_link link_text
    expect(link[:href]).to eq edit_guide_path(document)
    link
  end

  def the_form_should_be_prepopulated
    expect(find_field('Title').value).to eq "Sample Published Edition"
  end
end
