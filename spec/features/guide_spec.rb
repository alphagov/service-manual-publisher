require 'rails_helper'

RSpec.describe "creating guides", type: :feature do
  let(:api_double) { double(:publishing_api) }

  before do
    topic1 = create(:topic, title: "My Topic Number 1", path: "/service-manual/topic-path1")
    topic2 = create(:topic, title: "My Topic Number 2", path: "/service-manual/topic-path2")
    create(:topic_section, topic: topic1, title: "My Topic Section Number 1")
    create(:topic_section, topic: topic2, title: "My Topic Section Number 2")

    create(:guide_community, :with_published_edition, title: "Technology Community")

    topic = create(:topic)
    create(:topic_section, topic: topic)
    visit root_path
    click_link "Create a Guide"

    allow_any_instance_of(GuideSearchIndexer).to receive(:index)
    allow_any_instance_of(Guide).to receive(:topic).and_return topic
  end

  let(:topic) do
    create(:topic)
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
    expect(edition.update_type).to eq "minor"
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

    guide.latest_edition.tap do |edition|
      # set editor to another user so we can approve this edition
      edition.author = User.create!(name: "Editor", email: "email@example.org")
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
    it 'displays an alert if it fails' do
      api_error = GdsApi::HTTPClientError.new(
        422,
        "An error occurred",
        "error" => { "message" => "An error occurred" }
      )
      expect(PUBLISHING_API).to receive(:put_content).and_raise(api_error)

      fill_in_guide_form
      click_first_button "Save"

      within ".full-error-list" do
        expect(page).to have_content("An error occurred")
      end
    end
  end

  describe "action buttons" do
    it "a new guide can only be sent for review" do
      guide = create(:guide, :with_draft_edition)
      visit edit_guide_path(guide)

      expect(page).to     have_button("Send for review")
      expect(page).to_not have_button("Approve for publication")
      expect(page).to_not have_button("Publish")
    end

    it "a review requested guide can only be approved" do
      guide = create(:guide, :with_review_requested_edition)
      visit edit_guide_path(guide)

      expect(page).to_not have_button("Send for review")
      expect(page).to     have_button("Approve for publication")
      expect(page).to_not have_button("Publish")
    end

    it "a ready guide can only be published" do
      guide = create(:guide, :with_ready_edition)
      visit edit_guide_path(guide)

      expect(page).to_not have_button("Send for review")
      expect(page).to_not have_button("Approve for publication")
      expect(page).to     have_button("Publish")
    end
  end

private

  def fill_in_guide_form
    fill_in_final_url "/service-manual/the/path"
    select TopicSection.first.title, from: "Topic section"
    select "Technology Community", from: "Community"
    fill_in "Description", with: "This guide acts as a test case"

    fill_in "Title", with: "First Edition Title"
    fill_in "Body", with: "## First Edition Title"
  end
end

RSpec.describe "Updating guides", type: :feature do
  context "the guide has previously been published" do
    it "prevents users from editing the url slug" do
      @guide = create(:guide, :with_published_edition, slug: "/service-manual/topic-name/something")

      visit edit_guide_path(@guide)

      expect(find('input.guide-slug')['disabled']).to be_present
    end
  end

  it "shows the summary of validation errors" do
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
      expect(page).to have_content("Title can't be blank")
    end
  end

  it 'displays an alert if it fails' do
    guide = create(
      :guide,
      :with_draft_edition,
      :with_topic_section,
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
end
