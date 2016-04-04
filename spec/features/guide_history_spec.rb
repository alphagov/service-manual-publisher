require 'rails_helper'

RSpec.describe "Guide history", type: :feature do
  def stub_publisher
    publishing_api = double(:publishing_api)
    stub_const("PUBLISHING_API", publishing_api)
    allow(publishing_api).to receive(:put_content)
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))
    allow(publishing_api).to receive(:patch_links)
                            .with(an_instance_of(String), an_instance_of(Hash))
  end

  def create_guide_community
    @community = create(:guide_community)
  end

  def fill_out_new_guide_fields
    fill_in "Slug", with: "/service-manual/the/path"
    select @community.title, from: "Published by"
    fill_in "Description", with: "This guide acts as a test case"

    fill_in "Title", with: "First Edition Title"
    fill_in "Body", with: "## First Edition Title"
  end

  it "shows who created the new draft" do
    stub_publisher
    create_guide_community
    visit root_path
    click_on "Create a Guide"
    fill_out_new_guide_fields
    click_first_button "Save"

    click_on "Comments and history"

    expect(events.first).to eq "New draft created by Stub User"
  end

  it "shows who the guide is assigned to" do
    stub_publisher
    create_guide_community
    visit root_path
    click_on "Create a Guide"
    fill_out_new_guide_fields
    click_first_button "Save"

    click_on "Comments and history"

    expect(events.second).to eq "Assigned to Stub User"
  end

  it "shows a comment" do
    stub_publisher
    create_guide_community
    visit root_path
    click_on "Create a Guide"
    fill_out_new_guide_fields
    click_first_button "Save"

    click_on "Comments and history"

    within ".open-edition" do
      fill_in "Add new comment", with: "What a great piece of writing"
      click_button "Save comment"
    end

    expect(events.third).to include "What a great piece of writing"
  end

  it "shows state changes" do
    stub_publisher
    create_guide_community
    visit root_path
    click_on "Create a Guide"
    fill_out_new_guide_fields
    click_first_button "Save"
    click_first_button "Send for review"

    click_on "Comments and history"

    expect(events.third).to eq "Review requested by Stub User"
  end

  def events
    all(".event")
      .map(&:text)
      .reverse
  end
end
