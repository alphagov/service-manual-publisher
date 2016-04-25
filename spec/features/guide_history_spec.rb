require 'rails_helper'

RSpec.describe "Guide history", type: :feature do
  include ActiveSupport::Testing::TimeHelpers

  it "shows a header with pertinent edition information" do
    stub_publisher
    create_guide_community

    guide = create(:published_guide)
    guide.editions.where(state: "published").update_all(updated_at: "2004-11-24".to_time)
    guide.editions << build(:edition, version: 2, update_type: "minor")


    visit edit_guide_path(guide)

    click_on "Comments and history"

    headings = all(".panel-edition").map do |heading|
      heading.all(".panel-heading-part").map(&:text)
    end

    expect(headings).to eq [
      [
        "Edition #2", "Minor update", "Not yet published", ""
      ],
      [
        "Edition #1", "Major update", "Published on 24 November 2004",  '"change summary"'
      ],
    ]
  end

  it "shows a history of the latest edition" do
    stub_publisher
    create_guide_community

    travel_to "2004-11-24".to_time do
      visit root_path
      click_on "Create a Guide"
      fill_out_new_guide_fields
      click_first_button "Save"
    end

    travel_to "2004-11-25".to_time do
      click_on "Comments and history"

      within ".open-edition" do
        fill_in "Add new comment", with: "What a great piece of writing"
        click_button "Save comment"
      end
    end

    travel_to "2004-11-26".to_time do
      click_first_button "Send for review"
    end

    click_on "Comments and history"

    expect(events.first).to eq "24 November 2004 New draft created by Stub User"
    expect(events.second).to eq "24 November 2004 Assigned to Stub User"
    expect(events.third).to include "25 November 2004 Stub User What a great piece of writing"
    expect(events.fourth).to eq "26 November 2004 Review requested by Stub User"
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


RSpec.describe "Guide history", type: :feature do
  scenario "viewing previous editions" do
    guide = create(:published_guide)
    guide.editions << build(:edition, version: 2)

    visit guide_editions_path(guide)

    within_edition(1) do
      expect(events_visible).to be_empty
    end
    within_edition(2) do
      expect(page).to have_css(".event", text: "New draft created")
    end

    click_link "Edition #1"

    within_edition(1) do
      expect(page).to have_css(".event", text: "New draft created")
    end
    within_edition(2) do
      expect(events_visible).to be_empty
    end
  end

  def within_edition(number, &block)
    within(:xpath, "//div[contains(@class, 'panel') and div[contains(@class, 'panel-heading') and contains(., 'Edition ##{number}')]]", &block)
  end

  def events_visible
    all(".event")
  end
end
