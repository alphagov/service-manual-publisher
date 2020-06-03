require "rails_helper"

RSpec.describe "Topics", type: :feature do
  let(:api_double) { double(:publishing_api) }

  it "before creating a new topic it cannot be published" do
    visit root_path
    click_link "Manage Topics"
    click_link "Create a Topic"

    expect(page).to_not have_button("Publish")
  end

  it "allows you to choose whether the topic should appear on the homepage" do
    visit new_topic_path

    expect(page).to have_checked_field "Include on homepage?"
  end

  it "saves a draft topic", js: true do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
      .once
      .with(an_instance_of(String), be_valid_against_schema("service_manual_topic"))
    expect(api_double).to receive(:patch_links)
      .once
      .with(an_instance_of(String), an_instance_of(Hash))
    create(:guide, editions: [build(:edition, title: "Guide 1")])
    create(:guide, editions: [build(:edition, title: "Guide 2")])

    visit root_path
    click_link "Manage Topics"
    click_link "Create a Topic"

    fill_in "Title", with: "The title"
    fill_in "Description", with: "The description"
    check "Collapsed"
    uncheck "Include on homepage?"
    click_button "Add Heading"
    fill_in "Section title", with: "The section title"
    fill_in "Section description", with: "The section description"
    click_button "Save"

    expect(page).to have_field("Title", with: "The title")
    expect(page).to have_field("Description", with: "The description")
    expect(page).to have_checked_field("Collapsed")
    expect(page).to have_unchecked_field("Include on homepage?")

    expect(page).to have_field "Section title", with: "The section title"
    expect(page).to have_field "Section description", with: "The section description"
  end

  it "links to a preview from a saved draft" do
    create(:topic, title: "Agile Delivery", path: "/service-manual/agile-delivery-topic")

    visit root_path
    click_link "Manage Topics"
    click_link "Agile Delivery"

    expect(page).to have_link("Preview", href: %r{/service-manual/agile-delivery-topic})
  end

  it "update a topic to save another draft" do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
      .once
      .with(an_instance_of(String), be_valid_against_schema("service_manual_topic"))
    expect(api_double).to receive(:patch_links)
      .once
      .with(an_instance_of(String), an_instance_of(Hash))
    create(:topic, title: "Agile Delivery")

    visit root_path
    click_link "Manage Topics"
    click_link "Agile Delivery"

    fill_in "Description", with: "Updated description"

    click_button "Save"

    within(".alert") do
      expect(page).to have_content("Topic has been updated")
    end
    expect(page).to have_field("Description", with: "Updated description")
  end

  it "publish a topic" do
    stub_const("PUBLISHING_API", api_double)
    topic = create(:topic, :with_some_guides, title: "Technology")

    expect(api_double).to receive(:publish)
      .once.with(topic.content_id)

    visit root_path
    click_link "Manage Topics"
    click_link "Technology"

    click_on "Publish"

    within(".alert") do
      expect(page).to have_content("Topic has been published")
    end
  end

  it "displays validation messages when validation fails" do
    visit new_topic_path
    click_button "Save"

    within ".full-error-list" do
      expect(page).to have_content "Path must be present and start with '/service-manual/'"
      expect(page).to have_content "Title can't be blank"
    end
  end
end

RSpec.describe "topic editor", type: :feature do
  it "can view topics" do
    Topic.create!(
      path: "/service-manual/topic1",
      title: "Topic 1",
      description: "A Description",
    )
    visit root_path
    click_link "Manage Topics"
    click_link "Topic 1"
    expect(page).to have_link "View", href: "http://www.dev.gov.uk/service-manual/topic1"
  end
end
