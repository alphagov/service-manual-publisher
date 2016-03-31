require 'rails_helper'

RSpec.describe "Guide history", type: :feature do
  it "shows who created the new draft" do
    publishing_api = double(:publishing_api)
    stub_const("PUBLISHING_API", publishing_api)
    expect(publishing_api).to receive(:put_content)
                            .once
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))
    expect(publishing_api).to receive(:patch_links)
                            .once
                            .with(an_instance_of(String), an_instance_of(Hash))

    community = create(:guide_community)

    visit root_path
    click_on "Create a Guide"

    fill_in "Slug", with: "/service-manual/the/path"
    select community.title, from: "Published by"
    fill_in "Description", with: "This guide acts as a test case"

    fill_in "Title", with: "First Edition Title"
    fill_in "Body", with: "## First Edition Title"

    click_first_button "Save"

    click_on "Comments and history"

    expect(page).to have_content("New draft created by Stub User")
  end
end
