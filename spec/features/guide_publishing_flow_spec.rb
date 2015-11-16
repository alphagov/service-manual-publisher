require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Taking a guide through the publishing process", type: :feature do

  before do
    allow_any_instance_of(GuidePublisher).to receive(:put_draft)
  end

  context "latest edition is published" do
    let(:guide){ given_a_published_guide_exists title: "Standups" }

    before do
      publisher_double = double(:publisher)
      expect(GuidePublisher).to receive(:new).with(guide: guide).and_return(publisher_double)
      expect(publisher_double).to receive(:put_draft).once
    end

    it "should create a new draft edition when saving changes" do
      visit guides_path
      click_link "Create new edition"
      the_form_should_be_prepopulated_with_title "Standups"
      fill_in "Title", with: "Standup meetings"
      click_button "Save Draft"

      guide.reload
      expect(guide.editions.published.size).to eq 1
      expect(guide.editions.draft.size).to eq 1
      expect(guide.latest_edition.title).to eq "Standup meetings"
    end
  end

  it "prevents user from updating a draft if it has been published in the meantime" do
    guide = given_a_guide_exists title: "Agile development"
    visit guides_path
    click_link "Continue editing"

    guide.latest_edition.update_attributes(state: 'published') # someone else publishes it

    fill_in "Title", with: "Agile"

    click_button "Save Draft"

    within ".alert" do
      expect(page).to have_content "can not be changed after it's been published"
    end

    expect(guide.editions.map(&:title)).to match_array ["Agile development"]
    expect(guide.editions.map(&:state)).to match_array ["published"]
  end

  context "when publishing-api raises an exception" do
    let :api_error do
      GdsApi::HTTPClientError.new(422, "Error message stub", "error" => { "message" => "Error message stub" })
    end

    it "does not store a new draft edition" do
      guide = given_a_published_guide_exists
      expect(Guide.count).to eq 1
      expect(Edition.count).to eq 1

      expect_any_instance_of(GuidePublisher).to receive(:put_draft).and_raise api_error

      visit guides_path
      click_link "Create new edition"
      click_button "Save Draft"

      expect(Guide.count).to eq 1
      expect(Edition.count).to eq 1
    end

    it "shows api errors in the UI" do
      guide = given_a_published_guide_exists

      expect_any_instance_of(GuidePublisher).to receive(:put_draft).and_raise api_error

      visit guides_path
      click_link "Create new edition"
      click_button "Save Draft"

      within ".alert" do
        expect(page).to have_content('Error message stub')
      end
    end

    it "shows the correct state of the guide if publishing fails" do
      guide = given_a_guide_exists(state: 'approved')

      visit edition_path(guide.latest_edition)
      expect_any_instance_of(GuidePublisher).to receive(:publish).and_raise api_error

      click_button "Publish"

      within ".alert" do
        expect(page).to have_content('Error message stub')
      end

      within ".label" do
        expect(page).to have_content('Approved')
      end
    end
  end

  it "should not create a new edition if the latest edition isn't published" do
    guide = given_a_guide_exists state: 'draft', title: "Agile methodologies"
    visit guides_path
    click_link "Continue editing"
    fill_in "Title", with: "Agile"
    click_button "Save Draft"
    expect(current_path).to eq edit_guide_path guide

    expect(guide.editions.draft.size).to eq 1
    expect(guide.editions.map(&:title)).to match_array ["Agile"]
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

  it "should save a draft locally, sent it to Publishing API, then redirect to the front end when previewing" do
    guide = given_a_guide_exists state: 'draft', title: 'Test guide', slug: '/service-manual/preview-test'
    visit edit_guide_path(guide)
    fill_in "Title", with: "Changed Title"

    expect_any_instance_of(GuidePublisher).to receive(:put_draft)

    expect_external_redirect_to "http://draft-origin.dev.gov.uk/service-manual/preview-test" do
      click_button "Save Draft and Preview"
    end

    expect(guide.editions.map(&:title)).to match_array ["Changed Title"]
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
        edition = Generators.valid_edition(state: "review_requested", title: "Standups")
        guide = Guide.create!(latest_edition: edition, slug: "/service-manual/something")

        reviewer = User.new(name: "Keanu Reviews")
        login_as reviewer
        visit guides_path
        click_link "Standups"
        click_button "Mark as Approved"

        expect(current_path).to eq edition_path(edition)

        expect(page).to have_content "Thanks for approving this guide"
        expect(page).to have_content "Changes approved by Keanu Reviews"
        within ".label" do
          expect(page).to have_content "Approved"
        end
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

  describe "guide edition history" do
    it "allows seeing previous editions of a guide, but not change them" do
      guide = given_a_published_guide_exists(title: "First Edition")
      guide.latest_edition.dup.update_attributes(title: "Current Draft Edition", state: 'draft')

      expect(guide.editions.size).to eq 2

      visit guides_path
      click_link "Current Draft Edition"
      click_link "History"
      within("table tbody") do
        expect(page.find_all("tr").size).to eq 2
        page.find_all("tr a").last.click
      end

      expect(page).to have_content "First Edition"
      within ".alert-info" do
        expect(page).to have_content "You're looking at a past edition of this guide"
      end
      expect(page).to_not have_button "Publish Guide"
      expect(page).to_not have_button "Send for review"
    end
  end

  describe "guide edition changes" do
    it "shows exact changes in any fields" do
      guide = given_a_published_guide_exists(title: "First Edition", body: "### Hello")
      visit edit_guide_path(guide)
      fill_in "Title", with: "Second Edition"
      fill_in "Body", with: "## Hi"
      click_button "Save Draft"
      click_link "Changes"

      within ".title del" do
        expect(page).to have_content("First Edition")
      end

      within ".title ins" do
        expect(page).to have_content("Second Edition")
      end

      within ".body del" do
        expect(page).to have_content("### Hello")
      end

      within ".body ins" do
        expect(page).to have_content("## Hi")
      end
    end
  end

private

  def given_a_guide_exists(attributes = {})
    slug = attributes.delete(:slug) || '/service-manual/test-guide'
    edition = Generators.valid_edition(attributes)
    Guide.create!(latest_edition: edition, slug: slug)
  end

  def given_a_published_guide_exists(attributes = {})
    edition = Generators.valid_published_edition(attributes)
    slug = attributes.delete(:slug) || '/service-manual/published-test-guide'
    Guide.create!(latest_edition: edition, slug: slug)
  end

  def the_form_should_be_prepopulated_with_title(title)
    expect(find_field('Title').value).to eq title
  end

  def expect_external_redirect_to(external_url)
    yield
  rescue ActionController::RoutingError # Rack::Test raises when redirected to external urls
    expect(current_url).to eq external_url
  else
    raise "Missing external redirect"
  end
end
