require 'rails_helper'

RSpec.describe "Creating a guide", type: :feature do
  let(:api_double) { double(:publishing_api) }

  scenario "Save a new guide" do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
      .twice
      .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))
    expect(api_double).to receive(:patch_links)
      .twice
      .with(an_instance_of(String), an_instance_of(Hash))

    create(:guide_community, title: 'Technology Community')
    create(:topic_section, title: 'Relevant topic section')
    visit root_path
    click_link "Create a Guide"
    fill_in_guide_form

    click_first_button "Save"

    within ".alert" do
      expect(page).to have_content('saved')
    end

    guide = Guide.find_by_slug("/service-manual/the/path")
    edition = guide.latest_edition
    content_id = guide.content_id
    expect(content_id).to be_present
    expect(edition.version).to eq 1
    expect(edition.content_owner.title).to eq "Technology Community"
    expect(edition.title).to eq "First Edition Title"
    expect(edition.body).to eq "## First Edition Title"
    expect(edition.update_type).to eq "major"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false

    visit edit_guide_path(guide)

    expect(page).to have_field("Final URL", with: "/service-manual/the/path")
    expect(page).to have_field("Title", with: "First Edition Title")
    expect(page).to have_field("Description", with: "This guide acts as a test case")
    expect(page).to have_field("Body", with: "## First Edition Title")
    expect(page).to have_select("Community", selected: "Technology Community")

    fill_in "Title", with: "Second Edition Title"
    click_first_button "Save"

    within ".alert" do
      expect(page).to have_content('saved')
    end

    guide = Guide.find_by_slug("/service-manual/the/path")
    edition = guide.latest_edition
    expect(guide.content_id).to eq content_id
    expect(edition.title).to eq "Second Edition Title"
    expect(edition.draft?).to eq true
    expect(edition.published?).to eq false

    expect(page).to have_field("Final URL", with: "/service-manual/the/path")
    expect(page).to have_field("Title", with: "Second Edition Title")
    expect(page).to have_field("Description", with: "This guide acts as a test case")
    expect(page).to have_field("Body", with: "## First Edition Title")
    expect(page).to have_select("Community", selected: "Technology Community")
  end

  scenario "Review and publish a guide" do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
      .once
      .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))
    expect(api_double).to receive(:patch_links)
      .once
      .with(an_instance_of(String), an_instance_of(Hash))
    expect(api_double).to receive(:publish)
      .once
      .with(an_instance_of(String), 'major')
    stub_any_rummager_post

    create(:guide_community, title: 'Technology Community')
    create(:topic_section, title: 'Relevant topic section')
    visit root_path
    click_link "Create a Guide"
    fill_in_guide_form
    click_first_button "Save"
    guide = Guide.joins(:editions).merge(Edition.where(title: 'First Edition Title')).first
    visit edit_guide_path(guide)
    click_first_button "Send for review"

    within ".alert-success" do
      expect(page).to have_content('A review has been requested')
    end

    guide.latest_edition.tap do |edition|
      # set editor to another user so we can approve this edition
      edition.author = User.create!(name: "Editor", email: "email@example.org")
      edition.save!
    end

    visit edit_guide_path(guide)
    click_first_button "Approve for publication"

    within ".alert-success" do
      expect(page).to have_content('Thanks for approving this guide')
    end

    visit edit_guide_path(guide)
    click_first_button "Publish"

    within ".alert-success" do
      expect(page).to have_content('published')
    end

    assert_rummager_posted_item(title: 'First Edition Title')

    guide = Guide.find_by_slug("/service-manual/the/path")
    edition = guide.latest_edition
    expect(edition.title).to eq "First Edition Title"
    expect(edition.draft?).to eq false
    expect(edition.published?).to eq true
  end

  context "when the publishing-api returns an error" do
    it "displays the error to the user" do
      api_error = GdsApi::HTTPClientError.new(
        422,
        "An error occurred",
        "error" => { "message" => "An error occurred" }
      )
      expect(PUBLISHING_API).to receive(:put_content).and_raise(api_error)

      create(:guide_community, title: 'Technology Community')
      create(:topic_section, title: 'Relevant topic section')
      visit root_path
      click_link "Create a Guide"
      fill_in_guide_form
      click_first_button "Save"

      within ".full-error-list" do
        expect(page).to have_content("An error occurred")
      end
    end
  end

  it "does not show the 'About this update' fields for the first version" do
    visit root_path
    click_link "Create a Guide"

    # Prove that we're looking at the form
    expect(page).to have_field("Title")

    expect(page).to_not have_field("Major update")
    expect(page).to_not have_field("Minor update")
    expect(page).to_not have_field("Summary of change")
    expect(page).to_not have_field("Why the change is being made")
  end

private

  def fill_in_guide_form
    fill_in_final_url "/service-manual/the/path"
    select 'Relevant topic section', from: "Topic section"
    select "Technology Community", from: "Community"
    fill_in "Description", with: "This guide acts as a test case"

    fill_in "Title", with: "First Edition Title"
    fill_in "Body", with: "## First Edition Title"
  end
end

RSpec.describe "Updating a guide", type: :feature do
  let(:api_double) { double(:publishing_api) }

  context "when the guide has previously been published" do
    it "creates a new draft version" do
      allow_any_instance_of(GuideSearchIndexer).to receive(:index)
      stub_const("PUBLISHING_API", api_double)
      expect(api_double).to receive(:put_content)
        .once
        .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))
      expect(api_double).to receive(:patch_links)
        .once
        .with(an_instance_of(String), an_instance_of(Hash))
      guide = create(:guide, :with_published_edition, title: "Scrum")

      expect(guide.editions.count).to eq(4)
      expect(guide.editions.order(:created_at).last.version).to eq(1)

      visit guides_path
      within_guide_index_row("Scrum") do
        click_link "Scrum"
      end

      fill_in "Title", with: "Agile"
      fill_in "Summary of change", with: "Updated the title"
      fill_in "Why the change is being made", with: "Because the user's demand it"
      click_first_button 'Save'

      expect(guide.editions.count).to eq(5)
      expect(guide.editions.order(:created_at).last.version).to eq(2)
    end

    it "the new draft defaults to a major update and the new change note is empty" do
      create(:guide, :with_published_edition, title: "A guide to agile")

      visit guides_path
      within_guide_index_row("A guide to agile") do
        click_link "A guide to agile"
      end

      expect(find_field("Why the change is being made").value).to be_blank
      expect(find_field("Major update")).to be_checked
    end

    it "prevents users from editing the url slug" do
      guide = create(:guide, :with_published_edition, slug: "/service-manual/topic-name/something")

      visit edit_guide_path(guide)

      expect(find('input.guide-slug')['disabled']).to be_present
    end

    it "prevents users from changing the topic" do
      create(:topic_section,
        topic: create(:topic, title: "Another Topic"),
        title: "Section One"
      )

      guide = create(:guide, :with_published_edition)

      visit edit_guide_path(guide)

      select "Another Topic -> Section One", from: "Topic section"
      click_first_button "Save"

      within(".full-error-list") do
        expect(page).to have_content("Topic section cannot change to a different topic")
      end
    end
  end

  context "when the guide has never previously been published" do
    it "allows the user to edit the url slug", js: true do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      topic = create(:topic, path: "/service-manual/test-topic")
      guide = create(:guide, slug: "/service-manual/test-topic/something", topic: topic)

      visit edit_guide_path(guide)
      expect(find('input.guide-slug')['disabled']).not_to be_present
      fill_in "Slug", with: "changed"
      click_first_button "Save"

      visit edit_guide_path(guide)

      expect(page).to have_field("Slug", with: "changed")
      expect(page).to have_field("Final URL", with: "/service-manual/test-topic/changed")
    end

    it "allows users to change the topic" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      original_topic_section = create(:topic_section,
        title: "Original Section",
        topic: create(:topic, title: "Original Topic")
      )
      different_topic_section = create(:topic_section,
        title: "Another Section",
        topic: create(:topic, title: "Another Topic")
      )
      guide = create(:guide, topic_section: original_topic_section)

      visit edit_guide_path(guide)
      
      select "Another Topic -> Another Section", from: "Topic section", exact: true
      click_first_button "Save"

      visit edit_guide_path(guide)
      expect(page).to have_select("Topic section", selected: "Another Topic -> Another Section")
    end
  end

  scenario "Changing the author" do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    guide = create(:guide, :with_draft_edition)
    create(:user, name: "New Editor")

    visit edit_guide_path(guide)
    select "New Editor", from: "Author"
    click_first_button "Save"

    # reload the page to be sure the data has saved
    visit edit_guide_path(guide)

    expect(page).to have_select("Author", selected: "New Editor")
  end

  it "shows the summary of validation errors" do
    topic = create(:topic, path: "/service-manual/technology")
    guide = create(
      :guide,
      slug: "/service-manual/topic-name/something",
      editions: [build(:edition)],
      topic: topic
    )

    visit edit_guide_path(guide)
    fill_in "Title", with: ""
    click_first_button "Save"

    within(".full-error-list") do
      expect(page).to have_content("Title can't be blank")
    end
  end

  it "omits the redundant 'editions is invalid' error message" do
    topic = create(:topic, path: "/service-manual/technology")
    topic_section = create(:topic_section, topic: topic)
    guide = create(
      :guide,
      slug: "/service-manual/topic-name/something",
      editions: [build(:edition)],
    )
    topic_section.guides << guide
    visit edit_guide_path(guide)
    fill_in "Title", with: ""
    click_first_button "Save"

    within(".full-error-list") do
      expect(page).not_to have_content("Editions is invalid")
    end
  end

  context "when the publishing-api returns an error" do
    it "displays the error to the user" do
      guide = create(
        :guide,
        :with_draft_edition,
        slug: "/service-manual/topic-name/something"
      )

      api_error = GdsApi::HTTPClientError.new(
        422,
        "An error occurred",
        "error" => { "message" => "An error occurred" }
      )
      expect(PUBLISHING_API).to receive(:put_content).and_raise(api_error)

      visit edit_guide_path(guide)
      click_first_button "Save"

      within ".full-error-list" do
        expect(page).to have_content("An error occurred")
      end
    end

    it "keeps the changes made in form fields" do
      guide = create(:guide, :with_published_edition)

      api_error = GdsApi::HTTPClientError.new(
        422,
        "An error occurred",
        "error" => { "message" => "An error occurred" }
      )
      expect(PUBLISHING_API).to receive(:put_content).and_raise(api_error)

      visit edit_guide_path(guide)
      fill_in "Title", with: "Updated Title"
      fill_in "Summary of change", with: "Update Title"
      fill_in "Why the change is being made", with: "It was out of date"
      click_first_button 'Save'

      within ".full-error-list" do
        expect(page).to have_content('An error occurred')
      end

      expect(page).to have_field("Title", with: "Updated Title")
    end

    it "shows the current state of the guide" do
      guide = create(:guide, :with_ready_edition)

      visit edit_guide_path(guide)

      api_error = GdsApi::HTTPClientError.new(
        422,
        "An error occurred",
        "error" => { "message" => "An error occurred" }
      )
      expect(PUBLISHING_API).to receive(:publish).and_raise(api_error)

      click_first_button "Publish"

      within ".alert" do
        expect(page).to have_content('An error occurred')
      end

      within ".label" do
        expect(page).to have_content('Ready')
      end
    end
  end
end

RSpec.describe "Guide publishing action buttons", type: :feature do
  scenario "A new guide can only be sent for review" do
    guide = create(:guide, :with_draft_edition)
    visit edit_guide_path(guide)

    expect(page).to     have_button("Send for review")
    expect(page).to_not have_button("Approve for publication")
    expect(page).to_not have_button("Publish")
  end

  scenario "A review requested guide can only be approved" do
    guide = create(:guide, :with_review_requested_edition)
    visit edit_guide_path(guide)

    expect(page).to_not have_button("Send for review")
    expect(page).to     have_button("Approve for publication")
    expect(page).to_not have_button("Publish")
  end

  scenario "A ready guide can only be published" do
    guide = create(:guide, :with_ready_edition)
    visit edit_guide_path(guide)

    expect(page).to_not have_button("Send for review")
    expect(page).to_not have_button("Approve for publication")
    expect(page).to     have_button("Publish")
  end
end

RSpec.describe "'View' and 'Preview' buttons", type: :feature do
  describe "a draft guide" do
    before do
      guide = create(:guide, :with_draft_edition,
        slug: "/service-manual/topic-name/new-guide",
        )
      visit edit_guide_path(guide)
    end

    it "has a 'Preview' link" do
      expect(page).to have_link "Preview", href: "http://draft-origin.dev.gov.uk/service-manual/topic-name/new-guide"
    end

    it "does not have a 'View on website' button" do
      expect(page).to_not have_button "View on website"
    end
  end

  describe "a published guide" do
    before do
      guide = create(:guide, :with_published_edition,
        slug: "/service-manual/topic-name/just-published",
        )
      visit edit_guide_path(guide)
    end

    it "does not have a 'Preview' link" do
      expect(page).to_not have_button "Preview"
    end

    it "has a 'View on website' link" do
      expect(page).to have_link "View on website", href: "http://www.dev.gov.uk/service-manual/topic-name/just-published"
    end
  end

  describe "a draft that was previously published" do
    before do
      guide = create(:guide, :with_previously_published_edition,
        slug: "/service-manual/topic-name/published-guide",
      )
      visit edit_guide_path(guide)
    end

    it "has a 'Preview' link" do
      expect(page).to have_link "Preview", href: "http://draft-origin.dev.gov.uk/service-manual/topic-name/published-guide"
    end

    it "has a 'View on website' link" do
      expect(page).to have_link "View on website", href: "http://www.dev.gov.uk/service-manual/topic-name/published-guide"
    end
  end
end
