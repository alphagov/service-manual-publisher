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

    expect(sections_in_order).to eq ["Section A", "Section B", "Section C"]
  end

private

  def drag_topic_section_above(dragged_section_title, destination_section_title)
    handle = within_topic_section dragged_section_title do
      find('.js-topic-section-handle')
    end

    destination = within_topic_section destination_section_title do
      find('.js-topic-section-handle')
    end

    handle.drag_to destination
  end

  def sections_in_order
    all('.list-group-item input[placeholder="Heading Title"]').map &:value
  end
end
