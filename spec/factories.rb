FactoryGirl.define do
  factory :guide do
    transient do
      title "Example Guide"
    end
    slug "/service-manual/topic-name/test-guide#{SecureRandom.hex}"

    trait :with_draft_edition do
      editions {
        [build(:edition, title: title)]
      }
    end

    trait :with_topic_section do
      after(:create) do |guide, _evaluator|
        topic = create(:topic)
        topic_section = create(:topic_section, topic: topic)
        topic_section.guides << guide
      end
    end
  end

  factory :guide_community do
    slug "/service-manual/topic-name/test-guide#{SecureRandom.hex}"

    editions {
      [build(:community_edition, content_owner: nil)]
    }
  end

  factory :point do
    transient do
      title "Example Guide"
    end
    slug "/service-manual/topic-name/test-guide#{SecureRandom.hex}"

    trait :with_draft_edition do
      editions {
        [build(:edition, title: title)]
      }
    end
  end

  factory :edition do
    sequence :title do |n|
      "#{state} edition #{n}"
    end
    state "draft"
    phase "beta"
    description "Description"
    update_type "major"
    change_note "change note"
    change_summary "change summary"
    body "Heading"
    version 1
    content_owner { build(:guide_community) }
    author { build(:user) }
    created_by { author }
  end

  factory :community_edition, parent: :edition do
    sequence :title do |n|
      "#{n} Community"
    end
  end

  factory :draft_guide, parent: :guide do
    editions {
      [build(:edition, state: "draft")]
    }
  end

  factory :review_requested_guide, parent: :guide do
    editions {
      [build(:edition, state: "review_requested")]
    }
  end

  factory :ready_guide, parent: :guide do
    editions {
      [build(:edition, state: "ready")]
    }
  end

  factory :published_guide, parent: :guide do
    transient do
      title "Example Guide"
      body "The quick brown fox jumped over the lazy dog."
    end

    editions {
      [
      build(:edition, state: "draft", title: title, body: body),
      build(:edition, state: "review_requested", title: title, body: body),
      build(:edition, state: "ready", title: title, body: body),
      build(:edition, state: "published", title: title, body: body),
      ]
    }
  end

  factory :published_guide_community, parent: :published_guide, class: 'GuideCommunity'

  factory :unpublished_guide, parent: :guide do
    transient do
      title "An Unpublished Guide"
      body "Some Body Text"
    end

    editions {
      [
        build(:edition, state: "draft", title: title, body: body),
        build(:edition, state: "published", title: title, body: body),
        build(:edition, state: "unpublished", title: title, body: body),
      ]
    }
  end

  factory :unpublished_point, parent: :guide, class: 'Point' do
    transient do
      title "An Unpublished Point"
      body "Some Body Text"
      description "A summary"
    end

    editions {
      [
        build(:edition, state: "draft", title: title, body: body, description: description),
        build(:edition, state: "published", title: title, body: body, description: description),
        build(:edition, state: "unpublished", title: title, body: body, description: description),
      ]
    }
  end

  factory :user do
    name "Test User"
    permissions ["signin"]
    email "test-user@example.com"
  end

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

  factory :draft_edition, parent: :edition do
  end

  factory :ready_edition, parent: :edition do
    state "ready"
  end

  factory :published_edition, parent: :edition do
    state "published"
  end

  factory :unpublished_edition, parent: :edition do
    state "unpublished"
  end

  factory :review_requested_edition, parent: :edition do
    state "review_requested"
  end

  factory :slug_migration do
    slug "/something"

    trait :completed do
      completed true
    end

    trait :not_completed do
      completed false
    end

    trait :with_redirect_to do
      redirect_to "/path-to-redirect-to"
    end
  end

  factory :topic_section do
    title "Topic Section Title"
    description "Topic Section Description"
  end
end
