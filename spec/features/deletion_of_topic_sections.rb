require 'rails_helper'

RSpec.describe "Deletion of topic sections", type: :feature do
  let(:delete_button_selector) { '.js-delete-list-group-item' }
  let(:topic) { create(:topic, :with_some_guides) }

  it "lets you delete empty topic sections" do
    empty_section = topic.topic_sections.create!(
      title: "Empty Group",
      description: "Empty group description",
    )

    visit edit_topic_path(topic)

    within_topic_section(empty_section.title) do
      expect(page).to have_css delete_button_selector
    end
  end

  it "does not let you delete topic sections that contain guides" do
    visit edit_topic_path(topic)

    section_with_guides = topic.topic_sections[0]

    within_topic_section(section_with_guides.title) do
      expect(page).not_to have_css delete_button_selector
    end
  end
end
