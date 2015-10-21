require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Taking a guide through the publishing process", type: :feature do

  before do
    allow_any_instance_of(GuidePublisher).to receive(:publish!)
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

  it "should allow editing an existing draft" do
    guide = given_a_guide_exists state: 'draft'
    visit guides_path
    link = there_should_be_a_control_link "Continue editing", document: guide
    link.click
    fill_in "Title", with: "Sample Published Edition 2"
    click_button "Publish"
    expect(current_path).to eq root_path

    expect(guide.editions.published.size).to eq 1
    expect(guide.editions.draft.size).to eq 0
    expect(guide.editions.map(&:title)).to match_array ["Sample Published Edition 2"]
  end

private

  def given_a_guide_exists(state:)
    edition = Generators.valid_edition
    edition.state = state
    edition.title = 'Sample Published Edition'
    Guide.create!(latest_edition: edition, slug: "/test/slug_published")
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
