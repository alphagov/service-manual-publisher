FactoryGirl.define do
  factory :guide do
    transient do
      title "Example Guide"
      body "The quick brown fox jumped over the lazy dog."
      edition_factory :edition
    end
    slug "/service-manual/topic-name/test-guide#{SecureRandom.hex}"

    # a guide can't exist without an edition, so by default include one draft
    editions {
      [build(edition_factory, title: title, body: body)]
    }

    trait :with_draft_edition do
      # noop
    end

    trait :with_published_edition do
      editions {
        [
          build(edition_factory, state: "draft", title: title, body: body),
          build(edition_factory, state: "review_requested", title: title, body: body),
          build(edition_factory, state: "ready", title: title, body: body),
          build(edition_factory, state: "published", title: title, body: body)
        ]
      }
    end

    trait :with_previously_published_edition do
      editions {
        [
          build(edition_factory, state: "draft", title: title, body: body),
          build(edition_factory, state: "review_requested", title: title, body: body),
          build(edition_factory, state: "ready", title: title, body: body),
          build(edition_factory, state: "published", title: title, body: body),
          build(edition_factory, state: "draft", title: title, body: body)
        ]
      }
    end

    trait :has_been_unpublished do
      editions {
        [
          build(edition_factory, state: "draft", title: title, body: body),
          build(edition_factory, state: "review_requested", title: title, body: body),
          build(edition_factory, state: "ready", title: title, body: body),
          build(edition_factory, state: "published", title: title, body: body),
          build(edition_factory, state: "unpublished")
        ]
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

  factory :guide_community, parent: :guide, class: GuideCommunity do
    transient do
      title "Example Guide Community"
      edition_factory :community_edition
    end
  end

  factory :point, parent: :guide, class: Point do
    transient do
      sequence :title do |n|
        "Point #{n}. Point Title"
      end
      edition_factory :summary_edition
    end
    slug "/service-manual/service-standard/#{SecureRandom.hex}"
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
    content_owner nil
    sequence :title do |n|
      "#{n} Community"
    end
  end

  factory :summary_edition, parent: :edition do
    summary "Description"
  end

  factory :draft_guide, parent: :guide

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

  factory :published_guide, parent: :guide, traits: [:with_published_edition]
  factory :published_guide_community, parent: :guide_community, traits: [:with_published_edition]

  factory :unpublished_guide, parent: :guide, traits: [:has_been_unpublished]
  factory :unpublished_point, parent: :point, traits: [:has_been_unpublished]

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
