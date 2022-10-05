require "rails_helper"

RSpec.describe "Re-ordering guides", type: :feature, js: true do
  before do
    stub_any_publishing_api_call

    # Ensure that all elements are within the browser 'viewport' when dragging
    # things around by making the page really tall
    page.driver.resize(1024, 2000)
  end

  it "displays guides in order of position" do
    topic = create(:topic)
    section = create(:topic_section, title: "Section 1", topic:)
    topic.topic_sections << section

    section.guides << create(:guide, title: "Guide B")
    section.guides << create(:guide, title: "Guide A")
    section.guides << create(:guide, title: "Guide C")

    visit edit_topic_path(topic)

    expect(guides_within_section("Section 1")).to eq ["Guide B", "Guide A", "Guide C"]
  end

  it "lets you re-order guides" do
    topic = create(:topic)
    section = create(:topic_section, title: "Section 1", topic:)
    topic.topic_sections << section

    section.guides << create(:guide, title: "Guide B")
    section.guides << create(:guide, title: "Guide A")
    section.guides << create(:guide, title: "Guide C")

    visit edit_topic_path(topic)
    drag_guide_above("Guide A", "Guide B")

    click_button "Save"

    expect(guides_within_section("Section 1")).to eq ["Guide A", "Guide B", "Guide C"]
  end

  it "does not let you move guides between sections" do
    topic = create(:topic)
    section1 = create(:topic_section, title: "Section 1", topic:)
    section2 = create(:topic_section, title: "Section 2", topic:)
    topic.topic_sections = [section1, section2]

    section1.guides << create(:guide, title: "Guide B")
    section2.guides << create(:guide, title: "Guide A")

    visit edit_topic_path(topic)
    drag_guide_above("Guide A", "Guide B")

    expect(guides_within_section("Section 1")).to eq ["Guide B"]
    expect(guides_within_section("Section 2")).to eq ["Guide A"]
  end

  it "remembers order changes when you add a heading" do
    topic = create(:topic)
    section = create(:topic_section, title: "Section 1", topic:)
    topic.topic_sections << section

    section.guides << create(:guide, title: "Guide B")
    section.guides << create(:guide, title: "Guide A")
    section.guides << create(:guide, title: "Guide C")

    visit edit_topic_path(topic)
    drag_guide_above("Guide A", "Guide B")

    click_button "Add Heading"

    expect(guides_within_section("Section 1")).to eq ["Guide A", "Guide B", "Guide C"]
  end

private

  def handle_for_guide(title)
    find(:xpath, sprintf(%{//ul[contains(@class, "js-guide-list")]/li[.//*[contains(text(), "%<title>s")]]//span[contains(@class, "js-guide-handle")]}, title:))
  end

  def drag_guide_above(dragged_guide_title, destination_guide_title)
    handle_for_guide(dragged_guide_title).drag_to(
      handle_for_guide(destination_guide_title),
    )
  end

  def guides_within_section(section_title)
    within_topic_section(section_title) do
      all(".js-guide-list .list-group-item").map(&:text)
    end
  end
end
