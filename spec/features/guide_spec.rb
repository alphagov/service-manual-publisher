require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "creating guides", type: :feature do
  let(:api_double) { double(:publishing_api) }

  before do
    ContentOwner.first_or_initialize(
      title: "Design Community",
      href:  "http://sm-11.herokuapp.com/designing-services/design-community/"
    ).save!
    visit root_path
    click_link "Create a Guide"

    allow_any_instance_of(SearchIndexer).to receive(:index)
  end

  it "has a prepopulated slug field" do
    expect(find_field('Slug').value).to eq "/service-manual/"
  end

  it "saves draft guide editions" do
    fill_in_guide_form

    expect(GdsApi::PublishingApiV2).to receive(:new).and_return(api_double).twice # save and update
    expect(api_double).to receive(:put_content)
                            .twice
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))

    click_first_button "Save"

    within ".alert" do
      expect(page).to have_content('created')
    end

    guide = Guide.find_by_slug("/service-manual/the/path")
    edition = guide.latest_edition
    content_id = guide.content_id
    expect(content_id).to be_present
    expect(edition.content_owner.title).to eq "Design Community"
    expect(edition.content_owner.href).to eq "http://sm-11.herokuapp.com/designing-services/design-community/"
    expect(edition.title).to eq "First Edition Title"
    expect(edition.body).to eq "## First Edition Title"
    expect(edition.update_type).to eq "major"
    expect(edition.change_note).to eq "Change Note"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false

    visit edit_guide_path(guide)
    fill_in "Guide title", with: "Second Edition Title"
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

    expect(GdsApi::PublishingApiV2).to receive(:new).and_return(api_double).twice
    expect(api_double).to receive(:put_content)
                            .once
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))
    expect(api_double).to receive(:publish)
                            .once
                            .with(an_instance_of(String), 'major')

    click_first_button "Save"
    guide = Guide.first
    visit edit_guide_path(guide)
    click_first_button "Send for review"

    Edition.first.tap do |edition|
      # set editor to another user so we can approve this edition
      edition.user = User.create!(name: "Editor", email: "email@example.org")
      edition.save!
    end

    visit edition_path(guide.latest_edition)
    click_first_button "Approve for publication"

    visit edition_path(guide.latest_edition)
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

  context "when creating a new guide" do
    context "when publishing raises an exception" do
      before do
        api_error = GdsApi::HTTPClientError.new(422, "Error message stub", "error" => { "message" => "Error message stub" })
        expect_any_instance_of(GdsApi::PublishingApiV2).to receive(:put_content).and_raise(api_error)
      end

      it "shows api errors" do
        fill_in_guide_form
        click_first_button "Save"

        within ".alert" do
          expect(page).to have_content('Error message stub')
        end
      end

      it "does not store a guide" do
        fill_in_guide_form
        click_first_button "Save"

        expect(Guide.count).to eq 0
        expect(Edition.count).to eq 0
      end
    end
  end

  context "when updating a guide" do
    it "prevents users from editing the url slug" do
      guide = Guide.create!(slug: "/service-manual/something", latest_edition: Generators.valid_edition)
      visit edit_guide_path(guide)
      expect(find('input.guide-slug')['disabled']).to be_present
    end

    it "shows the summary of validation errors" do
      guide = Guide.create!(slug: "/service-manual/something", latest_edition: Generators.valid_edition)
      visit edit_guide_path(guide)
      fill_in "Guide title", with: ""
      click_first_button "Save"

      within(".full-error-list") do
        expect(page).to have_content("title can't be blank")
      end
    end

    context "when publishing raises an exception" do
      let :api_error do
        GdsApi::HTTPClientError.new(422, "Error message stub", "error" => { "message" => "Error message stub" })
      end

      it "shows api errors" do
        edition = Generators.valid_edition(title: "something")
        guide = Guide.create!(slug: "/service-manual/something", latest_edition: edition)

        expect_any_instance_of(GuidePublisher).to receive(:put_draft).once.and_raise(api_error)

        visit edit_guide_path(guide)
        click_first_button "Save"

        within ".alert" do
          expect(page).to have_content('Error message stub')
        end
      end

      it "does not store a new extra edition" do
        edition = Generators.valid_edition(title: "Original Title")
        guide = Guide.create!(slug: "/service-manual/something", latest_edition: edition)

        expect_any_instance_of(GuidePublisher).to receive(:put_draft).once.and_raise(api_error)

        visit edit_guide_path(guide)
        fill_in "Guide title", with: "Changed Title"
        click_first_button "Save"

        expect(Guide.count).to eq 1
        expect(Guide.first.latest_edition.title).to_not eq "Changed Title"
        expect(Edition.count).to eq 1
      end
    end
  end

  describe "action buttons" do
    {
      send_for_review: "Send for review",
      approve_for_publication: "Approve for publication",
      publish:          "Publish",
    }.each do |name, title|
      define_method :"expect_#{name}_to_be" do |state|
        if state == :visible
          expect(page).to have_button title
        else
          expect(page).to_not have_button title
        end
      end
    end

    context "when a review can be requested" do
      before do
        edition = Generators.valid_edition
        Guide.create!(slug: "/service-manual/something", latest_edition: edition)
        visit edition_path(edition)
      end

      it "only allows requesting of reviews" do
        expect_send_for_review_to_be :visible
        expect_approve_for_publication_to_be :hidden
        expect_publish_to_be :hidden
      end
    end

    context "when it can be marked as approved" do
      before do
        edition = Generators.valid_edition(state: "review_requested")
        Guide.create!(slug: "/service-manual/something", latest_edition: edition)
        visit edition_path(edition)
      end

      it "only allows being marked at approved" do
        expect_send_for_review_to_be :hidden
        expect_approve_for_publication_to_be :visible
        expect_publish_to_be :hidden
      end
    end

    context "when it can be published" do
      before do
        edition = Generators.valid_edition(state: "approved")
        Guide.create!(slug: "/service-manual/something", latest_edition: edition)
        visit edition_path(edition)
      end

      it "only allows publishing" do
        expect_send_for_review_to_be :hidden
        expect_approve_for_publication_to_be :hidden
        expect_publish_to_be :visible
      end
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

        fill_in "Guide title", with: title
        expect(find_field('Slug').value).to eq expected_slug
      end
    end

    context "user edits slug manually" do
      it "does not generate slug", js: true do
        fill_in "Slug", with: "/service-manual/something"
        fill_in "Guide title", with: "My Guide Title"
        expect(find_field('Slug').value).to eq '/service-manual/something'
      end
    end
  end

private

  def fill_in_guide_form
    fill_in "Slug", with: "/service-manual/the/path"
    select "Design Community", from: "Published by"
    fill_in "Guide description", with: "This guide acts as a test case"

    fill_in "Guide title", with: "First Edition Title"
    fill_in "Body", with: "## First Edition Title"

    choose "Major update"
    fill_in "Summary of change", with: "Factual change"
    fill_in "Why the change is being made", with: "Change Note"
  end
end
