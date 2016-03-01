require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "creating guides", type: :feature do
  let(:api_double) { double(:publishing_api) }

  before do
    Generators.valid_guide_community(
      latest_edition: Generators.valid_edition(content_owner: nil, title: 'Technology Community')
      ).tap(&:save!)

    visit root_path
    click_link "Create a Guide"

    allow_any_instance_of(SearchIndexer).to receive(:index)
    allow_any_instance_of(Guide).to receive(:topic).and_return topic
    allow_any_instance_of(TopicPublisher).to receive(:publish_immediately)
  end

  let(:topic) do
    topic = Generators.valid_topic
    topic.save!
    topic
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
    expect(api_double).to receive(:put_links)
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
    expect(api_double).to receive(:put_links)
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
      Guide.create!(
        slug: "/service-manual/something",
        latest_edition: Generators.valid_approved_edition
      )
    end

    it "does not publish the guide" do
      visit edit_guide_path(guide)
      click_first_button "Publish"
      expect(page).to have_content "This guide could not be published because it is not included in a topic page."
    end
  end

  context "guide is included in a topic" do
    let :guide do
      Guide.create!(
        slug: "/service-manual/something",
        latest_edition: Generators.valid_approved_edition
      )
    end

    it "republishes the topic" do
      stub_const("PUBLISHING_API", api_double)
      allow(api_double).to receive(:put_content)
      allow(api_double).to receive(:publish)

      publisher_double = double(:topic_publisher)
      expect(TopicPublisher).to receive(:new).with(topic).and_return publisher_double
      expect(publisher_double).to receive(:publish_immediately)

      visit edit_guide_path(guide)
      click_first_button "Publish"
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
      fill_in "Title", with: ""
      click_first_button "Save"

      within(".full-error-list") do
        expect(page).to have_content("title can't be blank")
      end
    end

    it 'displays an alert if it fails' do
      publication = Publisher::PublicationResponse.new(success: false, errors: ['trouble'])
      allow_any_instance_of(Publisher).to receive(:save_draft).and_return(publication)

      edition = Generators.valid_edition(title: "something")
      guide = Guide.create!(slug: "/service-manual/something", latest_edition: edition)

      visit edit_guide_path(guide)
      click_first_button "Save"

      within ".alert" do
        expect(page).to have_content('trouble')
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

        fill_in "Title", with: title
        expect(find_field('Slug').value).to eq expected_slug
      end
    end

    context "user edits slug manually" do
      it "does not generate slug", js: true do
        fill_in "Slug", with: "/service-manual/something"
        fill_in "Title", with: "My Guide Title"
        expect(find_field('Slug').value).to eq '/service-manual/something'
      end
    end
  end

  describe "link validation" do
    context "with invalid links in document" do
      let :edition do
        Generators.valid_approved_edition(
          body: "[broken link](http://nothing.com)",
        )
      end

      let :guide do
        Generators.valid_guide(
          latest_edition: edition,
          slug: '/service-manual/guide-1',
        )
      end

      before do
        expect_any_instance_of(GovspeakUrlChecker).to receive(:find_broken_links)
          .and_return(["http://nothing.com"])
        guide.save!
      end

      it "does not allow documents to be published" do
        visit edit_guide_path(guide)
        click_first_button "Publish"

        within(".full-error-list") do
          error = "Latest edition body link 'http://nothing.com' is broken"
          expect(page).to have_content error
        end
      end

      it "allows publishing to be forced" do
        stub_const("PUBLISHING_API", api_double)
        expect(api_double).to receive(:publish).once

        visit edit_guide_path(guide)
        click_first_button "Publish"
        click_first_button "Publish with broken links"

        expect(page).to have_text "Guide has been published"

        guide = Guide.find_by_slug("/service-manual/guide-1")
        expect(guide).to be_present
        edition = guide.latest_edition
        expect(edition.published?).to eq true
      end
    end
  end

private

  def fill_in_guide_form
    fill_in "Slug", with: "/service-manual/the/path"
    select "Technology Community", from: "Published by"
    fill_in "Description", with: "This guide acts as a test case"

    fill_in "Title", with: "First Edition Title"
    fill_in "Body", with: "## First Edition Title"
  end
end
