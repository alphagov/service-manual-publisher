require "rails_helper"

RSpec.describe ":guide" do
  it "creates a topic and topic section by default" do
    guide = create(:guide)

    topic_section_guide = guide.topic_section_guides.first

    expect(topic_section_guide).to be_present
    expect(topic_section_guide).to be_persisted

    topic_section = topic_section_guide.topic_section
    topic = topic_section.topic

    expect(topic_section).to be_persisted
    expect(topic).to be_persisted
  end

  it "can be associated with a supplied topic" do
    topic = create(:topic)
    guide = create(:guide, topic: topic)

    expect(guide.topic).to eq(topic)

    # check we haven't produced any extra topics or topic sections
    expect(Topic.count).to eq(1)
    expect(TopicSection.count).to eq(1)
  end
end

RSpec.describe ":point" do
  it "does not create a topic by default" do
    point = create(:point)

    expect(point.topic).to be_blank

    # check we haven't produced any topics or topic sections
    expect(Topic.count).to eq(0)
    expect(TopicSection.count).to eq(0)
  end
end
