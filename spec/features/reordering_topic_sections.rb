require 'rails_helper'

RSpec.describe 'Re-ordering topic sections', type: :feature, js: true do
  before do
    stub_any_publishing_api_call

    # Ensure that all elements are within the browser 'viewport' when dragging
    # things around by making the page really tall
    page.driver.resize(1024, 2000)
  end

  it 'displays topic sections in order of position' do
    topic = create(:topic)

    topic.topic_sections << create(:topic_section, title: "Section B", topic: topic)
    topic.topic_sections << create(:topic_section, title: "Section A", topic: topic)
    topic.topic_sections << create(:topic_section, title: "Section C", topic: topic)

    visit edit_topic_path(topic)

    expect(sections_in_order).to eq ["Section B", "Section A", "Section C"]
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

  it 'remembers order changes when you add a heading' do
    topic = create(:topic)

    topic.topic_sections << create(:topic_section, title: "Section B", topic: topic)
    topic.topic_sections << create(:topic_section, title: "Section A", topic: topic)
    topic.topic_sections << create(:topic_section, title: "Section C", topic: topic)

    visit edit_topic_path(topic)

    drag_topic_section_above("Section A", "Section B")

    click_button "Add Heading"

    expect(sections_in_order).to eq ["Section A", "Section B", "Section C", ""]
  end

private

  def handle_for_topic_section(section_title)
    within_topic_section(section_title) { find('.js-topic-section-handle') }
  end

  def drag_topic_section_above(dragged_section_title, destination_section_title)
    handle_for_topic_section(dragged_section_title).drag_to(
      handle_for_topic_section(destination_section_title)
    )
  end

  def sections_in_order
    all('.list-group-item input[placeholder="Heading Title"]').map &:value
  end
end
