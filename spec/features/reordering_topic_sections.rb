require 'rails_helper'

RSpec.describe 'Re-ordering topic sections', type: :feature, js: true do
  before do
    stub_any_publishing_api_call

    # Ensure that all elements are within the browser 'viewport' when dragging
    # things around by making the page really tall
    page.driver.resize(1024, 2000)
  end

  it 'lets you re-order topic sections' do
    topic = create(:topic)

    topic.topic_sections << create(:topic_section, title: "Section B", topic: topic)
    topic.topic_sections << create(:topic_section, title: "Section A", topic: topic)
    topic.topic_sections << create(:topic_section, title: "Section C", topic: topic)

    visit edit_topic_path(topic)

    drag_topic_section_above("Section A", "Section B")

    click_button "Save"

    sections = all('.list-group-item input[placeholder="Heading Title"]')
    section_titles = sections.map { |section| section.value }

    expect(section_titles).to eq ["Section A", "Section B", "Section C"]
  end
end
