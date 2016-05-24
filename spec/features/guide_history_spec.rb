require 'rails_helper'

RSpec.describe "Guide history", type: :feature do
  include ActiveSupport::Testing::TimeHelpers

  it "shows a history of the latest edition" do
    john = create(:user, name: "John")
    sally = create(:user, name: "Sally")
    dave = create(:user, name: "Dave")

    stub_publisher
    create(:topic_section, topic: create(:topic))
    community = create(:guide_community)

    GDS::SSO.test_user = john

    travel_to "2004-11-24".to_time do
      visit root_path
      click_on "Create a Guide"
      fill_in_final_url "/service-manual/the/path"
      select TopicSection.first.title, from: "Topic section"
      select community.title, from: "Community"
      fill_in "Description", with: "This guide acts as a test case"
      fill_in "Title", with: "First Edition Title"
      fill_in "Body", with: "## First Edition Title"

      click_first_button "Save"
    end

    GDS::SSO.test_user = sally

    travel_to "2004-11-25".to_time do
      click_on "Comments and history"

      within ".open-edition" do
        fill_in "Add new comment", with: "What a great piece of writing"
        click_button "Save comment"
      end
    end

    GDS::SSO.test_user = dave

    travel_to "2004-11-26".to_time do
      click_first_button "Send for review"
    end

    GDS::SSO.test_user = sally

    click_on "Edit"

    travel_to "2004-11-27".to_time do
      click_first_button "Approve for publication"
    end

    click_on "Comments and history"

    expect(events[0].text).to eq "27 November 2004 Approved by Sally"
    expect(events[1].text).to eq "26 November 2004 Review requested by Dave"
    expect(events[2].text).to include "25 November 2004 Sally What a great piece of writing"
    expect(events[3].text).to eq "24 November 2004 Assigned to John"
    expect(events[4].text).to eq "24 November 2004 New draft created by John"
  end

  it "shows a header with pertinent edition information" do
    guide = create(:published_guide)
    first_published_edition = guide.editions.find_by(state: "published")
    first_published_edition.update_attribute(:updated_at, "2004-11-24".to_time)

    second_published_edition = build(:edition, version: 2, update_type: "minor", state: "published", updated_at: "2004-11-25".to_time)
    guide.editions << second_published_edition

    draft_edition = build(:edition, version: 3, update_type: "minor")
    guide.editions << draft_edition

    visit edit_guide_path(guide)

    click_on "Comments and history"

    within_edition(3) do
      expect(page).to have_content("Edition #3")
      expect(page).to have_content("Minor update")
      expect(page).to have_content("Not yet published")
      # A link that compares this version to the previous version
      expect(page).to have_link("View changes", href: edition_changes_path(second_published_edition, draft_edition))
    end

    within_edition(2) do
      expect(page).to have_content("Edition #2")
      expect(page).to have_content("Minor update")
      expect(page).to have_content("Published on 25 November 2004")
      # A link that compares this version to the previous version
      expect(page).to have_link("View changes", href: edition_changes_path(first_published_edition, second_published_edition))
    end

    within_edition(1) do
      expect(page).to have_content("Edition #1")
      expect(page).to have_content("Major update")
      expect(page).to have_content("Published on 24 November 2004")
      expect(page).to have_content('"change summary"')
      # A link that shows one large addition for the first version
      expect(page).to have_link("View changes", href: edition_changes_path(nil, first_published_edition))
    end
  end

  scenario "viewing previous editions" do
    guide = create(:published_guide)
    guide.editions << build(:edition, version: 2)

    visit guide_editions_path(guide)

    within_edition(1) do
      expect(events).to be_empty
    end
    within_edition(2) do
      expect(page).to have_css(".event", text: "New draft created")
    end

    click_link "Edition #1"

    within_edition(1) do
      expect(page).to have_css(".event", text: "New draft created")
    end
    within_edition(2) do
      expect(events).to be_empty
    end
  end

  def within_edition(number, &block)
    within(:xpath, "//div
                        [contains(@class, 'panel')]
                        [div
                          [contains(@class, 'panel-heading')]
                          [contains(., 'Edition ##{number}')]
                        ]", &block)
  end

  def events
    all(".event")
  end

  def stub_publisher
    publishing_api = double(:publishing_api)
    stub_const("PUBLISHING_API", publishing_api)
    allow(publishing_api).to receive(:put_content)
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_guide'))
    allow(publishing_api).to receive(:patch_links)
                            .with(an_instance_of(String), an_instance_of(Hash))
  end
end
