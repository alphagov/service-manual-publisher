require "rails_helper"

RSpec.describe TopicSectionGuide, "validations" do
  it "adds an error if the guide exists in another topic section" do
    topic = create(:topic)
    topic_section = create(:topic_section, topic: topic)
    guide = create(:guide)

    TopicSectionGuide.create!(topic_section: topic_section, guide: guide)

    topic_section_guide = TopicSectionGuide.new(topic_section: topic_section, guide: guide)
    topic_section_guide.save

    expect(
      topic_section_guide.errors.full_messages
    ).to include("Guide can only be in one topic section")
  end
end

RSpec.describe TopicSectionGuide, "#default_position_to_next_in_list" do
  it "automatically sets position to 1 for the first guide in a topic section" do
    topic_section = create(:topic_section)

    topic_section_guide = create(:topic_section_guide, topic_section: topic_section)
    expect(topic_section_guide.position).to eq 1
  end

  it "automatically sets position to the next guide in an existing section" do
    topic_section = create(:topic_section)

    create(:topic_section_guide, topic_section: topic_section, position: 5)
    topic_section_guide = create(:topic_section_guide, topic_section: topic_section)

    expect(topic_section_guide.position).to eq 6
  end

  it "only considers guides in the same section when setting position" do
    topic = create(:topic)
    topic_section = create(:topic_section, topic: topic)
    another_topic_section = create(:topic_section, topic: topic)

    create(:topic_section_guide, topic_section: another_topic_section, position: 5)
    topic_section_guide = create(:topic_section_guide, topic_section: topic_section)

    expect(topic_section_guide.position).to eq 1
  end
end
