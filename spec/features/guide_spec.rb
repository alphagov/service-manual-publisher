require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "creating guides", type: :feature do
  let(:api_double) { double(:publishing_api) }

  before do
    community_guide_edition = Generators.valid_edition(title: 'Design Community')
    community_guide = Guide.create!(
      community: true,
      latest_edition: community_guide_edition,
      slug: "/service-manual/design-community"
    )
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
    expect(edition.title).to eq "First Edition Title"
    expect(edition.body).to eq "## First Edition Title"
    expect(edition.update_type).to eq "minor"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false

    expect(find_published_by_dropdown('Design Community')).to be_selected

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
        fill_in_guide_form(guide_title: 'Getting things done')
        click_first_button "Save"

        relevant_editions = Edition.where(title: 'Getting things done')
        relevant_guides = Guide.joins(:editions).merge(relevant_editions)

        expect(relevant_guides.count).to eq 0
        expect(relevant_editions.count).to eq 0
      end
    end
  end

  context "when updating a guide" do
    context "the guide has previously been published" do
      before do
        @guide = Guide.create!(slug: "/service-manual/something", latest_edition: Generators.valid_published_edition)
      end

      it "prevents users from editing the url slug" do
        visit edit_guide_path(@guide)
        expect(find('input.guide-slug')['disabled']).to be_present
      end
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

        expect(guide.latest_edition.title).to_not eq "Changed Title"
        expect(guide.editions.count).to eq 1
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
        guide = Guide.create!(slug: "/service-manual/something", latest_edition: edition)
        visit edit_guide_path(guide)
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
        guide = Guide.create!(slug: "/service-manual/something", latest_edition: edition)
        visit edit_guide_path(guide)
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
        guide = Guide.create!(slug: "/service-manual/something", latest_edition: edition)
        visit edit_guide_path(guide)
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

  def fill_in_guide_form(attributes = {})
    guide_title = attributes.fetch(:guide_title, "First Edition Title")

    fill_in "Slug", with: "/service-manual/the/path"
    select "Design Community", from: "Published by"
    fill_in "Guide description", with: "This guide acts as a test case"

    fill_in "Guide title", with: guide_title
    fill_in "Body", with: "## First Edition Title"
  end

  # The select2 plugin makes Capybara's have_select helper unusable for the
  # Published By dropdown
  def find_published_by_dropdown(text)
    find(:css, '#guide_latest_edition_attributes_content_owner_id option', text: text)
  end
end
