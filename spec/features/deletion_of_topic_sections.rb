require 'rails_helper'

RSpec.describe "Deletion of topic sections", type: :feature do
  it "lets you delete empty topic sections" do
    topic = create(:topic)
    section_without_guides = topic.topic_sections.create!(title: "Empty Group")

    visit edit_topic_path(topic)

    within_topic_section(section_without_guides.title) do
      expect(page).to have_css '.js-delete-list-group-item'
    end
  end

  it "does not let you delete topic sections that contain guides" do
    topic = create(:topic, :with_some_guides)
    section_with_guides = topic.topic_sections[0]

    visit edit_topic_path(topic)

    within_topic_section(section_with_guides.title) do
      expect(page).not_to have_css '.js-delete-list-group-item'
    end
  end
end
