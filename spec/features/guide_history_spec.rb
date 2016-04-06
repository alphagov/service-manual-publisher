require 'rails_helper'

RSpec.describe "Guide history", type: :feature do
  it "shows a history of the latest edition" do
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

    click_first_button "Send for review"

    click_on "Comments and history"

    expect(events.first).to eq "06 April 2016 New draft created by Stub User"
    expect(events.second).to eq "06 April 2016 Assigned to Stub User"
    expect(events.third).to include "06 April 2016 Stub User What a great piece of writing"
    expect(events.fourth).to eq "06 April 2016 Review requested by Stub User"
  end

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
    select @community.title, from: "Community"
    fill_in "Description", with: "This guide acts as a test case"

    fill_in "Title", with: "First Edition Title"
    fill_in "Body", with: "## First Edition Title"
  end

  def events
    all(".event")
      .map(&:text)
      .reverse
  end
end
