require 'rails_helper'

RSpec.describe TopicSection, '#default_position_to_next_in_list' do
  it 'automatically sets position to 1 for the first section in a topic' do
    topic = create(:topic)

    topic_section = create(:topic_section, topic: topic)
    expect(topic_section.position).to eq 1
  end

  it 'automatically sets position to the next section in an existing topic' do
    topic = create(:topic)

    create(:topic_section, position: 5, topic: topic)
    topic_section = create(:topic_section, topic: topic)

    expect(topic_section.position).to eq 6
  end

  it 'only considers sections in the same topic when setting position' do
    topic = create(:topic)
    another_topic = create(:topic, path: '/service-manual/another-topic')

    create(:topic_section, position: 5, topic: another_topic)
    topic_section = create(:topic_section, topic: topic)

    expect(topic_section.position).to eq 1
  end
end
