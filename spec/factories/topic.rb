FactoryGirl.define do
  factory :topic do
    title "Agile Delivery"
    path "/service-manual/agile-delivery"
    description "Agile description"

    trait :with_some_guides do
      after(:create) do |topic, _evaluator|
        guide1 = create(:published_guide)
        topic_section1 = topic.topic_sections.create!(
          title: "Group 1 title",
          description: "Group 1 description",
        )
        topic_section1.guides << guide1

        guide2 = create(:published_guide)
        topic_section2 = topic.topic_sections.create!(
          title: "Group 2",
          description: "Group 2 description",
        )
        topic_section2.guides << guide2
      end
    end
  end
end
