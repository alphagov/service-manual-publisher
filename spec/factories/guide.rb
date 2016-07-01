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
          build(edition_factory, :draft, title: title, body: body),
          build(edition_factory, :review_requested, title: title, body: body),
          build(edition_factory, :ready, title: title, body: body),
          build(edition_factory, :published, title: title, body: body)
        ]
      }
    end

    trait :with_previously_published_edition do
      editions {
        [
          build(edition_factory, :draft, title: title, body: body),
          build(edition_factory, :review_requested, title: title, body: body),
          build(edition_factory, :ready, title: title, body: body),
          build(edition_factory, :published, title: title, body: body),
          build(edition_factory, :draft, title: title, body: body)
        ]
      }
    end

    trait :has_been_unpublished do
      editions {
        [
          build(edition_factory, :draft, title: title, body: body),
          build(edition_factory, :review_requested, title: title, body: body),
          build(edition_factory, :ready, title: title, body: body),
          build(edition_factory, :published, title: title, body: body),
          build(edition_factory, :unpublished)
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

  # -----

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
end
