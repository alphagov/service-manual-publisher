require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Taking a guide through the publishing process", type: :feature do

  let(:fake_publishing_api) { FakePublishingApi.new }

  before do
    stub_const('PUBLISHING_API', fake_publishing_api)
    allow_any_instance_of(SearchIndexer).to receive(:index)
    allow_any_instance_of(Guide).to receive(:topic).and_return build(:topic)
  end

  context "latest edition is published" do
    it "creates a new draft version" do
      guide = create(:published_guide, title: "Scrum")

      expect(guide.editions.count).to eq(4)
      expect(guide.editions.order(:created_at).last.version).to eq(1)

      visit guides_path
      within_guide_index_row("Scrum") do
        click_link "Scrum"
      end

      fill_in "Title", with: "Agile"
      fill_in "Why the change is being made", with: "Update Title"

      click_first_button 'Save'

      expect(guide.editions.count).to eq(5)
      expect(guide.editions.order(:created_at).last.version).to eq(2)
    end

    it "defaults to a major update and the new change note is empty" do
      guide = create(:published_guide, title: "A guide to agile")
      visit guides_path

      within_guide_index_row("A guide to agile") do
        click_link "A guide to agile"
      end
      expect(find_field("Why the change is being made").value).to be_blank

      expect(find_field("Major update")).to be_checked
    end

    it "indexes documents for search" do
      guide = create(:guide, :with_draft_edition)

      indexer = double(:indexer)
      expect(SearchIndexer).to receive(:new).with(guide).and_return(indexer)
      expect(indexer).to receive(:index)
      visit guides_path
      within_guide_index_row(guide.title) do
        click_link guide.title
      end
      click_first_button "Send for review"
      click_first_button "Approve for publication"
      click_first_button "Publish"
    end
  end

  context "when publishing-api raises an exception" do
    let :api_error do
      GdsApi::HTTPClientError.new(422, "Error message stub", "error" => { "message" => "Error message stub" })
    end

    it "keeps the changes made in form fields" do
      guide = create(:published_guide)

      expect(fake_publishing_api).to receive(:put_content).and_raise api_error

      visit edit_guide_path(guide)
      fill_in "Title", with: "Updated Title"
      fill_in "Why the change is being made", with: "Update Title"
      click_first_button 'Save'

      the_form_should_be_prepopulated_with_title "Updated Title"

      expect(guide.editions.published.count).to eq 1
      expect(guide.editions.draft.count).to eq 1
    end

    it "shows api errors in the UI" do
      guide = create(:published_guide, title: "Scrum")

      expect(fake_publishing_api).to receive(:put_content).and_raise api_error

      visit guides_path
      within_guide_index_row("Scrum") do
        click_link "Scrum"
      end
      fill_in "Why the change is being made", with: "Fix a typo"
      click_first_button 'Save'

      within ".alert" do
        expect(page).to have_content('Error message stub')
      end
    end

    it "shows the correct state of the guide if publishing fails" do
      guide = create(:ready_guide)

      visit edit_guide_path(guide)
      expect(fake_publishing_api).to receive(:publish).and_raise api_error

      click_first_button "Publish"

      within ".alert" do
        expect(page).to have_content('Error message stub')
      end

      within ".label" do
        expect(page).to have_content('Ready')
      end
    end
  end

  it "creates a new edition with the same version number if the latest edition isn't published" do
    guide = create(:guide, :with_draft_edition)

    expect(guide.editions.count).to eq(1)
    expect(guide.editions.order(:created_at).last.version).to eq(1)

    visit guides_path
    within_guide_index_row(guide.title) do
      click_link guide.title
    end
    fill_in "Title", with: "Agile"
    click_first_button 'Save'

    expect(guide.editions.count).to eq(2)
    expect(guide.editions.order(:created_at).last.version).to eq(1)
  end

  it "should record who's the last editor" do
    stub_user.update_attribute :name, "John Smith"
    guide = create(:guide, :with_draft_edition)
    visit edit_guide_path(guide)
    fill_in "Title", with: "An amended title"
    click_first_button 'Save'
    visit guides_path
    within_guide_index_row('An amended title') do
      within ".last-edited-by" do
        expect(page).to have_content "John Smith"
      end
    end
  end

  it "should save a draft locally and send it to Publishing API" do
    guide = create(:guide, :with_draft_edition, title: "Original Title", slug: "/service-manual/topic-name/preview-test")
    visit edit_guide_path(guide)
    fill_in "Title", with: "Changed Title"

    expect(fake_publishing_api).to receive(:put_content)

    click_first_button "Save"

    expect(guide.editions.map(&:title)).to match_array ["Changed Title", "Original Title"]
    expect(page).to have_link "Preview", href: "http://draft-origin.dev.gov.uk/service-manual/topic-name/preview-test"
  end

  context "with a review requested" do
    it "lists editions that need a review" do
      guide = create(:guide, :with_draft_edition, slug: "/service-manual/topic-name/something")

      visit edit_guide_path(guide)
      click_first_button "Send for review"
      expect(page).to have_content "Review Requested"
    end

    context "approved by another user" do
      it "lists editions that are approved" do
        guide = create(:review_requested_guide, slug: "/service-manual/topic-name/something")

        reviewer = create(:user, name: "Keanu Reviews")
        login_as reviewer
        visit guides_path
        click_link guide.title
        click_first_button "Approve for publication"

        expect(current_path).to eq edit_guide_path(guide)
        expect(page).to have_content "Thanks for approving this guide"
        expect(page).to have_content "Changes approved by Keanu Reviews"

        visit root_path
        within_guide_index_row(guide.title) do
          within ".label" do
            expect(page).to have_content "Ready"
          end
        end
      end
    end

    context "without approval" do
      it "does not allow guides to be published" do
        guide = create(:review_requested_guide, slug: "/service-manual/topic-name/something")
        visit edit_guide_path(guide)
        expect(page).to_not have_button "Publish"
      end
    end
  end

  describe "guide edition history" do
    it "allows seeing previous edition changes" do
      guide = create(:published_guide, title: "Original Title")

      visit edit_guide_path(guide)
      fill_in "Title", with: "Current Draft Edition"
      fill_in "Why the change is being made", with: "Update Title"

      expect(fake_publishing_api).to receive(:put_content)

      click_first_button "Save"

      visit guides_path
      click_link "Current Draft Edition"
      click_link "Comments and history"
      view_edition_links = page.find_all("a").select {|a| a.text == "View changes"}
      expect(view_edition_links.size).to eq 2
      view_edition_links.last.click

      expect(page).to have_content "Original Title"
      within ".alert-info" do
        expect(page).to have_content "You're looking at a past edition of this guide"
      end
      expect(page).to_not have_button "Publish Guide"
      expect(page).to_not have_button "Send for review"
    end
  end

private

  def the_form_should_be_prepopulated_with_title(title)
    expect(find_field('Title').value).to eq title
  end

  class FakePublishingApi
    def put_content(*args)
    end

    def patch_links(*args)
    end

    def publish(*args)
    end
  end
end
