require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Taking a guide through the publishing process", type: :feature do

  before do
    allow_any_instance_of(GuidePublisher).to receive(:process)
  end

  context "latest edition is published" do
    it "should create a new draft edition if the latest edition is published" do
      guide = given_a_published_guide_exists

      publisher_double = double(:publisher)
      expect(GuidePublisher).to receive(:new).with(guide: guide).and_return(publisher_double)
      expect(publisher_double).to receive(:process)

      visit guides_path
      click_button "Create new edition"
      the_form_should_be_prepopulated
      expect(guide.editions.published.size).to eq 1
      expect(guide.editions.draft.size).to eq 1
    end
  end

  context "latest edition is not published" do
    it "should not save an extra draft if someone else clicks the link in the meantime" do
      guide = given_a_published_guide_exists

      visit guides_path
      guide.latest_edition.state = "draft"
      guide.latest_edition.save!
      click_button "Create new edition"

      expect(guide.editions.published.size).to eq 0
      expect(guide.editions.draft.size).to eq 1
    end
  end

  context "when guide publishing raises an exception" do
    let :api_error do
      GdsApi::HTTPClientError.new(422, "Error message stub", "error" => { "message" => "Error message stub" })
    end

    it "does not store a new draft edition" do
      guide = given_a_published_guide_exists
      expect(Guide.count).to eq 1
      expect(Edition.count).to eq 1

      expect_any_instance_of(GuidePublisher).to receive(:process).and_raise api_error

      visit guides_path
      click_button "Create new edition"

      expect(Guide.count).to eq 1
      expect(Edition.count).to eq 1
    end

    it "shows api errors" do
      guide = given_a_published_guide_exists

      expect_any_instance_of(GuidePublisher).to receive(:process).and_raise api_error

      visit guides_path
      click_button "Create new edition"

      within ".alert" do
        expect(page).to have_content('Error message stub')
      end
    end
  end

  it "should not create a new edition if the latest edition isn't published" do
    guide = given_a_guide_exists state: 'draft'
    visit guides_path
    click_link "Continue editing"
    fill_in "Title", with: "Sample Published Edition 2"
    click_button "Save Draft"
    expect(current_path).to eq root_path

    expect(guide.editions.draft.size).to eq 1
    expect(guide.editions.map(&:title)).to match_array ["Sample Published Edition 2"]
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

  context "with a review requested" do
    it "lists editions that need a review" do
      edition = Generators.valid_edition
      guide = Guide.create!(latest_edition: edition, slug: "/service-manual/something")

      visit edit_guide_path(guide)
      click_button "Send for review"
      visit guides_path
      expect(page).to have_content "Review Requested"
    end

    context "approved by another user" do
      it "lists editions that are approved" do
        edition = Generators.valid_edition(state: "review_requested")
        guide = Guide.create!(latest_edition: edition, slug: "/service-manual/something")

        reviewer = User.new(name: "Some User")
        login_as reviewer
        visit guides_path
        click_link "Continue editing"
        click_button "Mark as Approved"
        expect(page).to have_content "Thanks for approving this guide"
        expect(page).to have_content "Approved"
      end
    end

    context "without approval" do
      it "does not allow guides to be published" do
        edition = Generators.valid_edition(state: "review_requested")
        guide = Guide.create!(latest_edition: edition, slug: "/service-manual/something")
        visit edit_guide_path(guide)
        expect(page).to_not have_button "Publish"
      end
    end

    context "approved by the same user" do
      it "does not allow the same user to approve it"
    end
  end

private

  def given_a_published_guide_exists
    edition = Generators.valid_published_edition(
      title: 'Sample Published Edition',
    )
    Guide.create!(latest_edition: edition, slug: "/service-manual/test/slug_published")
  end

  def given_a_guide_exists(state:)
    edition = Generators.valid_edition(
      state: state,
      title: 'Sample Published Edition',
    )
    Guide.create!(latest_edition: edition, slug: "/service-manual/test/slug_published")
  end

  def the_form_should_be_prepopulated
    expect(find_field('Title').value).to eq "Sample Published Edition"
  end
end
