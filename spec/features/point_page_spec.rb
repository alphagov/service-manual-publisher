require 'rails_helper'

RSpec.describe 'Create a point page', type: :feature do
  it 'successfully creates a point' do
    topic1 = create(:topic, title: "My Topic Number 1", path: "/service-manual/topic-path1")
    create(:topic_section, topic: topic1, title: "My Topic Section Number 1")

    visit root_path
    click_link "Create a Point"

    publishing_api = double(:publishing_api)
    stub_const("PUBLISHING_API", publishing_api)
    expect(publishing_api).to receive(:put_content)
    expect(publishing_api).to receive(:patch_links)

    fill_in_final_url '/service-manual/service-standard/point-1'
    select "My Topic Section Number 1", from: "Topic section"
    fill_in "Description", with: "User needs should be your first focus."
    fill_in "Summary", with: "Understand user needs. Research to develop a deep knowledge of who the service users are and what that means for the design of the service."
    fill_in "Title", with: "Understand user needs"
    fill_in "Body", with: "## Why it's in the standard"
    click_first_button "Save"

    within ".alert" do
      expect(page).to have_content('saved')
    end

    # Reload the page to avoid any false positive assertions on
    # the content of the fields
    visit current_path

    expect(page).to have_field('Final URL', with: "/service-manual/service-standard/point-1")
    expect(page).to have_field('Description', with: "User needs should be your first focus.")
    expect(page).to have_field('Summary', with: "Understand user needs. Research to develop a deep knowledge of who the service users are and what that means for the design of the service.")
    expect(page).to have_field('Title', with: "Understand user needs")
    expect(page).to have_field('Body', with: "## Why it's in the standard")
  end

  it 'does not have a content owner field' do
    visit root_path
    click_link "Create a Point"

    expect(page).to_not have_field('Community')
  end
end
