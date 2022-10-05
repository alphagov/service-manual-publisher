require "rails_helper"

RSpec.describe "Deletion of topic sections", type: :feature, js: true do
  before do
    stub_any_publishing_api_call
  end

  it "allows you to delete empty topic sections" do
    topic = create(:topic)
    section_without_guides = create(:topic_section, title: "Empty Group", topic:)
    topic.topic_sections << section_without_guides

    visit edit_topic_path(topic)

    within_topic_section(section_without_guides.title) do
      find(".js-delete-list-group-item").click
    end

    click_button "Save"

    expect(page).not_to have_css ".topic-section-list .list-group-item"
  end

  it "does not display the delete icon for sections that contain guides" do
    topic = create(:topic, :with_some_guides)
    section_with_guides = topic.topic_sections[0]

    visit edit_topic_path(topic)

    within_topic_section(section_with_guides.title) do
      expect(page).not_to have_css ".js-delete-list-group-item"
    end
  end
end
