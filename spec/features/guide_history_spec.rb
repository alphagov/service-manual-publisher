require "rails_helper"

RSpec.describe "Guide history", type: :feature do
  include ActiveSupport::Testing::TimeHelpers

  it "shows a history of the latest edition" do
    stub_publisher

    john = create(:user, name: "John")
    sally = create(:user, name: "Sally")
    dave = create(:user, name: "Dave")

    create(:topic_section, topic: create(:topic), title: "A beautiful section")
    community = create(:guide_community)

    GDS::SSO.test_user = john

    travel_to "2004-11-24".to_time do
      visit root_path
      click_on "Create a Guide"
      fill_in_final_url "/service-manual/the/path"
      select "A beautiful section", from: "Topic section"
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

    GDS::SSO.test_user = john

    travel_to "2004-11-25".to_time do
      click_on "Edit"
      select "Sally", from: "Author"

      click_first_button "Save"
    end

    GDS::SSO.test_user = sally

    travel_to "2004-11-26".to_time do
      click_first_button "Send for review"
    end

    GDS::SSO.test_user = john

    click_on "Edit"

    travel_to "2004-11-27".to_time do
      click_first_button "Approve for publication"
    end

    GDS::SSO.test_user = dave

    click_on "Edit"

    travel_to "2004-11-28".to_time do
      click_first_button "Publish"
    end

    click_on "Comments and history"

    expect(events[0].text).to eq "28 November 2004\nPublished by Dave"
    expect(events[1].text).to eq "27 November 2004\nApproved by John"
    expect(events[2].text).to eq "26 November 2004\nReview requested by Sally"
    expect(events[3].text).to eq "25 November 2004\nAssigned to Sally by John"
    expect(events[4].text).to include "25 November 2004\nSally\nWhat a great piece of writing"
    expect(events[5].text).to eq "24 November 2004\nAssigned to John"
    expect(events[6].text).to eq "24 November 2004\nNew draft created by John"
  end

  it "shows a header with pertinent edition information" do
    guide = create(:guide, :with_published_edition)
    first_published_edition = guide.editions.find_by(state: "published")
    first_published_edition.update!(updated_at: "2004-11-24".to_time)

    second_published_edition = build(:edition, version: 2, update_type: "minor", state: "published", updated_at: "2004-11-25".to_time)
    guide.editions << second_published_edition

    draft_edition = build(:edition, version: 3, update_type: "minor")
    guide.editions << draft_edition

    visit edit_guide_path(guide)

    click_on "Comments and history"

    within_guide_history_edition(3) do
      expect(page).to have_content("Edition #3")
      expect(page).to have_content("Minor update")
      expect(page).to have_content("Not yet published")
      # A link that compares this version to the previous version
      expect(page).to have_link("View changes", href: edition_changes_path(second_published_edition, draft_edition))
    end

    within_guide_history_edition(2) do
      expect(page).to have_content("Edition #2")
      expect(page).to have_content("Minor update")
      expect(page).to have_content("Published on 25 November 2004")
      # A link that compares this version to the previous version
      expect(page).to have_link("View changes", href: edition_changes_path(first_published_edition, second_published_edition))
    end

    within_guide_history_edition(1) do
      expect(page).to have_content("Edition #1")
      expect(page).to have_content("Major update")
      expect(page).to have_content("Published on 24 November 2004")
      expect(page).to have_content('"A summary of the changes in this edition"')
      # A link that shows one large addition for the first version
      expect(page).to have_link("View changes", href: edition_changes_path(nil, first_published_edition))
    end
  end

  scenario "viewing previous editions" do
    guide = create(:guide, :with_published_edition)
    guide.editions << build(:edition, version: 2)

    visit guide_editions_path(guide)

    within_guide_history_edition(1) do
      expect(events).to be_empty
    end
    within_guide_history_edition(2) do
      expect(page).to have_css(".event", text: "New draft created")
    end

    click_link "Edition #1"

    expect(page).to have_css(".alert", text: "You're looking at a past edition of this guide")

    within_guide_history_edition(1) do
      expect(page).to have_css(".event", text: "New draft created")
    end
    within_guide_history_edition(2) do
      expect(events).to be_empty
    end
  end

  def events
    all(".event")
  end

  def stub_publisher
    publishing_api = double(:publishing_api)
    stub_const("PUBLISHING_API", publishing_api)
    allow(publishing_api).to receive(:put_content)
      .with(an_instance_of(String), be_valid_against_publisher_schema("service_manual_guide"))
    allow(publishing_api).to receive(:patch_links)
      .with(an_instance_of(String), an_instance_of(Hash))
    allow(publishing_api).to receive(:publish)
      .with(an_instance_of(String))
  end
end
