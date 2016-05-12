require 'rails_helper'

RSpec.describe TopicSectionGuide, 'validations' do
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
