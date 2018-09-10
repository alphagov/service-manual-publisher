FactoryBot.define do
  factory :topic do
    title { "Agile Delivery" }
    sequence :path do |n|
      "/service-manual/topic-#{n}"
    end
    description { "Agile description" }

    trait :with_some_guides do
      after(:create) do |topic, _evaluator|
        guide1 = create(:guide, :with_published_edition)
        topic_section1 = create(:topic_section,
          title: "Group 1 title",
          description: "Group 1 description",
          topic: topic
        )
        topic_section1.guides << guide1

        guide2 = create(:guide, :with_published_edition)
        topic_section2 = create(:topic_section,
          title: "Group 2",
          description: "Group 2 description",
          topic: topic
        )
        topic_section2.guides << guide2
      end
    end
  end
end
