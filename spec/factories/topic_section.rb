FactoryBot.define do
  # Example Usage
  #
  # Create a topic section with the title Hello World
  # -> create(:topic_section, title: "Hello World")
  #
  # Create a topic section with associated guides
  # -> create(:topic_section, guides: [create(:guide), create(:guide)])

  factory :topic_section do
    transient do
      guides { [] }
    end

    topic
    title { "Topic Section Title" }
    description { "Topic Section Description" }
    position { 0 }

    after(:build) do |topic_section, evaluator|
      evaluator.guides.each do |guide|
        topic_section_guide = TopicSectionGuide.new(guide: guide, topic_section: topic_section)
        topic_section.topic_section_guides << topic_section_guide
      end
    end
  end
end
