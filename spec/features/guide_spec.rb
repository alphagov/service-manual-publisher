require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "creating guides", type: :feature do
  let(:api_double) { double(:publishing_api) }

  before do
    edition = build(
      :edition,
      content_owner: nil,
      title: "Technology Community"
    )
    create(:guide_community, latest_edition: edition)

    visit root_path
    click_link "Create a Guide"

    allow_any_instance_of(SearchIndexer).to receive(:index)
    allow_any_instance_of(Guide).to receive(:topic).and_return topic
  end

  let(:topic) do
    create(:topic)
  end

  it "has a prepopulated slug field" do
    expect(find_field('Slug').value).to eq "/service-manual/"
  end

  it "saves draft guide editions" do
    fill_in_guide_form

    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
                            .twice
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))
    expect(api_double).to receive(:patch_links)
                            .twice
                            .with(an_instance_of(String), an_instance_of(Hash))

    click_first_button "Save"

    within ".alert" do
      expect(page).to have_content('created')
    end

    guide = Guide.find_by_slug("/service-manual/the/path")
    edition = guide.latest_edition
    content_id = guide.content_id
    expect(content_id).to be_present
    expect(edition.version).to eq 1
    expect(edition.content_owner.title).to eq "Technology Community"
    expect(edition.title).to eq "First Edition Title"
    expect(edition.body).to eq "## First Edition Title"
    expect(edition.update_type).to eq "minor"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false

    visit edit_guide_path(guide)
    fill_in "Title", with: "Second Edition Title"
    click_first_button "Save"

    within ".alert" do
      expect(page).to have_content('updated')
    end

    guide = Guide.find_by_slug("/service-manual/the/path")
    edition = guide.latest_edition
    expect(guide.content_id).to eq content_id
    expect(edition.title).to eq "Second Edition Title"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false
  end

  it "publishes guide editions" do
    fill_in_guide_form

    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
                            .once
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))
    expect(api_double).to receive(:patch_links)
                            .once
                            .with(an_instance_of(String), an_instance_of(Hash))
    expect(api_double).to receive(:publish)
                            .once
                            .with(an_instance_of(String), 'minor')

    click_first_button "Save"
    guide = Guide.joins(:editions).merge(Edition.where(title: 'First Edition Title')).first
    visit edit_guide_path(guide)
    click_first_button "Send for review"

    guide.editions.first.tap do |edition|
      # set editor to another user so we can approve this edition
      edition.user = User.create!(name: "Editor", email: "email@example.org")
      edition.save!
    end

    visit edit_guide_path(guide)
    click_first_button "Approve for publication"

    visit edit_guide_path(guide)
    click_first_button "Publish"

    within ".alert-success" do
      expect(page).to have_content('published')
    end

    guide = Guide.find_by_slug("/service-manual/the/path")
    edition = guide.latest_edition
    expect(edition.title).to eq "First Edition Title"
    expect(edition.draft?).to eq false
    expect(edition.published?).to eq true
  end

  context "guide is not included in a topic" do
    before do
      expect_any_instance_of(Guide).to receive(:topic).and_return nil
    end

    let :guide do
      create(:ready_guide, slug: "/service-manual/topic-name/something")
    end

    it "does not publish the guide" do
      visit edit_guide_path(guide)
      click_first_button "Publish"
      expect(page).to have_content "This guide could not be published because it is not included in a topic page."
    end
  end

  context "when creating a new guide" do
    it 'displays an alert if it fails' do
      publication = Publisher::PublicationResponse.new(success: false, errors: ['trouble'])
      allow_any_instance_of(Publisher).to receive(:save_draft).and_return(publication)

      fill_in_guide_form
      click_first_button "Save"

      within ".alert" do
        expect(page).to have_content('trouble')
      end
    end
  end

  context "when updating a guide" do
    context "the guide has previously been published" do
      before do
        @guide = create(:published_guide, slug: "/service-manual/topic-name/something")
      end

      it "prevents users from editing the url slug" do
        visit edit_guide_path(@guide)
        expect(find('input.guide-slug')['disabled']).to be_present
      end
    end

    it "shows the summary of validation errors" do
      guide = Guide.create!(slug: "/service-manual/topic-name/something", latest_edition: build(:edition))
      visit edit_guide_path(guide)
      fill_in "Title", with: ""
      click_first_button "Save"

      within(".full-error-list") do
        expect(page).to have_content("title can't be blank")
      end
    end

    it 'displays an alert if it fails' do
      publication = Publisher::PublicationResponse.new(success: false, errors: ['trouble'])
      allow_any_instance_of(Publisher).to receive(:save_draft).and_return(publication)

      guide = create(:guide, slug: "/service-manual/topic-name/something")

      visit edit_guide_path(guide)
      click_first_button "Save"

      within ".alert" do
        expect(page).to have_content('trouble')
      end
    end
  end

  describe "action buttons" do
    it "a new guide can only be sent for review" do
      guide = create(:guide)
      visit edit_guide_path(guide)

      expect(page).to     have_button("Send for review")
      expect(page).to_not have_button("Approve for publication")
      expect(page).to_not have_button("Publish")
    end

    it "a review requested guide can only be approved" do
      guide = create(:review_requested_guide)
      visit edit_guide_path(guide)

      expect(page).to_not have_button("Send for review")
      expect(page).to     have_button("Approve for publication")
      expect(page).to_not have_button("Publish")
    end

    it "a ready guide can only be published" do
      guide = create(:ready_guide)
      visit edit_guide_path(guide)

      expect(page).to_not have_button("Send for review")
      expect(page).to_not have_button("Approve for publication")
      expect(page).to     have_button("Publish")
    end
  end

  describe "slug generation" do
    it "generates slug", js: true do
      {
        "Guide title": "guide-title",
        "slug--with-----hyphens": "slug-with-hyphens",
        "       space    slugs  ": "space-slugs",
        'other things !@#$%^&*()_-+=/\\': "other-things",
      }.each do |title, expected_slug|
        expected_slug = "/service-manual/#{expected_slug}"

        fill_in "Title", with: title
        expect(find_field('Slug').value).to eq expected_slug
      end
    end

    context "user edits slug manually" do
      it "does not generate slug", js: true do
        fill_in "Slug", with: "/service-manual/topic-name/something"
        fill_in "Title", with: "My Guide Title"
        expect(find_field('Slug').value).to eq '/service-manual/topic-name/something'
      end
    end
  end

private

  def fill_in_guide_form
    fill_in "Slug", with: "/service-manual/the/path"
    select "Technology Community", from: "Community"
    fill_in "Description", with: "This guide acts as a test case"

    fill_in "Title", with: "First Edition Title"
    fill_in "Body", with: "## First Edition Title"
  end
end
