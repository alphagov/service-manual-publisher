require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Taking a guide through the publishing process", type: :feature do

  let(:fake_publishing_api) { FakePublishingApi.new }

  before do
    stub_const('PUBLISHING_API', fake_publishing_api)
    allow_any_instance_of(SearchIndexer).to receive(:index)
    allow_any_instance_of(Guide).to receive(:topic).and_return build(:topic)
    allow_any_instance_of(TopicPublisher).to receive(:publish_immediately)
  end

  context "latest edition is published" do
    it "should create a new draft edition when saving changes" do
      guide = create(:published_guide)

      visit guides_path
      within_guide_index_row(guide.title) do
        click_link "Edit"
      end
      the_form_should_be_prepopulated_with_title guide.title
      fill_in "Title", with: "Standup meetings"
      fill_in "Why the change is being made", with: "Be more specific in the title"
      click_first_button 'Save'

      guide.reload
      expect(guide.editions.published.size).to eq 1
      expect(guide.editions.draft.size).to eq 1
      expect(guide.latest_edition.title).to eq "Standup meetings"
    end

    it "defaults to a major update and the new change note is empty" do
      guide = create(:published_guide)
      visit guides_path

      within_guide_index_row(guide.title) do
        click_link "Edit"
      end
      expect(find_field("Why the change is being made").value).to be_blank

      expect(find_field("Major update")).to be_checked
    end

    it "indexes documents for search" do
      guide = create(:guide)

      indexer = double(:indexer)
      expect(SearchIndexer).to receive(:new).with(guide).and_return(indexer)
      expect(indexer).to receive(:index)
      visit guides_path
      within_guide_index_row(guide.title) do
        click_link "Edit"
      end
      click_first_button "Send for review"
      click_first_button "Approve for publication"
      click_first_button "Publish"
    end
  end

  it "creates a new draft version if the original has been published in the meantime" do
    guide = create(:guide)
    visit guides_path
    within_guide_index_row(guide.title) do
      click_link "Edit"
    end

    # someone else publishes it
    guide.latest_edition.update_attributes(state: 'published')

    fill_in "Title", with: "Agile"

    click_first_button 'Save'

    expect(guide.editions.published.map(&:title)).to match_array [guide.title]
    expect(guide.editions.draft.map(&:title)).to match_array ["Agile"]
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
      guide = create(:published_guide)

      expect(fake_publishing_api).to receive(:put_content).and_raise api_error

      visit guides_path
      within_guide_index_row(guide.title) do
        click_link "Edit"
      end
      fill_in "Why the change is being made", with: "Fix a typo"
      click_first_button 'Save'

      within ".alert" do
        expect(page).to have_content('Error message stub')
      end
    end

    it "shows the correct state of the guide if publishing fails" do
      guide = create(:approved_guide)

      visit edit_guide_path(guide)
      expect(fake_publishing_api).to receive(:publish).and_raise api_error

      click_first_button "Publish"

      within ".alert" do
        expect(page).to have_content('Error message stub')
      end

      within ".label" do
        expect(page).to have_content('Approved')
      end
    end
  end

  it "should not create a new edition if the latest edition isn't published" do
    guide = create(:guide)

    visit guides_path
    within_guide_index_row(guide.title) do
      click_link "Edit"
    end
    fill_in "Title", with: "Agile"
    click_first_button 'Save'
    expect(current_path).to eq edit_guide_path guide

    expect(guide.editions.draft.size).to eq 1
    expect(guide.editions.map(&:title)).to match_array ["Agile"]
  end

  it "should record who's the last editor" do
    stub_user.update_attribute :name, "John Smith"
    guide = create(:guide)
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

  it "should save a draft locally, sent it to Publishing API, then redirect to the front end when previewing" do
    guide = create(:guide, slug: '/service-manual/preview-test')
    visit edit_guide_path(guide)
    fill_in "Title", with: "Changed Title"

    expect(fake_publishing_api).to receive(:put_content)

    expect_external_redirect_to "http://draft-origin.dev.gov.uk/service-manual/preview-test" do
      click_first_button "Save and preview"
    end

    expect(guide.editions.map(&:title)).to match_array ["Changed Title"]
  end

  context "with a review requested" do
    it "lists editions that need a review" do
      guide = create(:guide, slug: "/service-manual/something")

      visit edit_guide_path(guide)
      click_first_button "Send for review"
      expect(page).to have_content "Review Requested"
    end

    context "approved by another user" do
      it "lists editions that are approved" do
        guide = create(:review_requested_guide, slug: "/service-manual/something")

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
            expect(page).to have_content "Approved"
          end
        end
      end
    end

    context "without approval" do
      it "does not allow guides to be published" do
        guide = create(:review_requested_guide, slug: "/service-manual/something")
        visit edit_guide_path(guide)
        expect(page).to_not have_button "Publish"
      end
    end
  end

  describe "guide edition history" do
    it "allows seeing previous edition changes" do
      guide = create(:published_guide)
      first_edition = guide.latest_edition
      guide.latest_edition.dup.update_attributes(title: "Current Draft Edition", state: 'draft')

      expect(guide.editions.size).to eq 2

      visit guides_path
      click_link "Current Draft Edition"
      click_link "Comments and history"
      view_edition_links = page.find_all("a").select {|a| a.text == "View changes"}
      expect(view_edition_links.size).to eq 2
      view_edition_links.last.click

      expect(page).to have_content first_edition.title
      within ".alert-info" do
        expect(page).to have_content "You're looking at a past edition of this guide"
      end
      expect(page).to_not have_button "Publish Guide"
      expect(page).to_not have_button "Send for review"
    end
  end

  describe "guide edition changes" do
    it "shows exact changes in any fields" do
      first_edition = create(:published_edition, title: "First Edition", body: "### Hello")
      guide = create(:published_guide, latest_edition: first_edition)

      visit edit_guide_path(guide)
      fill_in "Title", with: "Second Edition"
      fill_in "Body", with: "## Hi"
      fill_in "Why the change is being made", with: "Better greeting"
      click_first_button 'Save'
      click_link "Compare changes"

      within ".title del" do
        expect(page).to have_content(first_edition.title)
      end

      within ".title ins" do
        expect(page).to have_content("Second Edition")
      end

      within ".body del" do
        expect(page).to have_content(first_edition.body)
      end

      within ".body ins" do
        expect(page).to have_content("## Hi")
      end
    end

    it "shows all fields as additions if there are no previous editions" do
      guide = create(:guide)
      visit edition_changes_path(new_edition_id: guide.latest_edition.id)

      within ".title ins" do
        expect(page).to have_content(guide.latest_edition.title)
      end

      within ".body ins" do
        expect(page).to have_content(guide.latest_edition.body)
      end
    end
  end

private

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

  class FakePublishingApi
    def put_content(*args)
    end

    def patch_links(*args)
    end

    def publish(*args)
    end
  end
end
