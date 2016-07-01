FactoryGirl.define do

  # Example Usage
  # 
  # Create a guide with a single draft edition, with title "Hello World"
  # -> create(:guide, title: "Hello World")
  # 
  # Create a guide community, that has had a review requested
  # -> create(:guide_community, :has_had_review_requested)
  # 
  # Create a guide, which has an non conventional edition history
  # -> create(:guide, states: [:draft, :published, :ready])
  # 
  # Create a point, which has been published, with every edition created by bob.
  # Note that edition overrides title, body if specified
  # -> create(:point, :has_been_pubished, edition: {created_by: bob})
  # 
  # Create a guide with manually defined editions
  # -> create(:guide, editions: [create(:edition)])

  factory :guide do
    transient do
      title "Example Guide"
      body "The quick brown fox jumped over the lazy dog."
      edition nil
      edition_factory :edition
      # a guide can't exist without an edition, so by default include one draft
      states [:draft]
    end

    slug "/service-manual/topic-name/test-guide#{SecureRandom.hex}"

    trait :with_draft_edition do
      # noop
    end

    trait :with_review_requested_edition do
      states [:draft, :review_requested]
    end

    trait :with_ready_edition do
      states [:draft, :review_requested, :ready]
    end

    trait :with_published_edition do
      transient do
        states [:draft, :review_requested, :ready, :published]
      end
    end

    trait :with_previously_published_edition do
      transient do
        states [:draft, :review_requested, :ready, :published, :draft]
      end
    end

    trait :has_been_unpublished do
      transient do
        states [:draft, :review_requested, :ready, :published, :unpublished]
      end
    end

    trait :with_topic_section do
      after(:create) do |guide, _evaluator|
        topic = create(:topic)
        topic_section = create(:topic_section, topic: topic)
        topic_section.guides << guide
      end
    end

    # once the guide has been built, create an edition of the right type for
    # every state the guide should have been in, passing through attributes in
    # edition.
    after(:build) do |guide, evaluator|
      if guide.editions.empty?
        evaluator.states.each do |state|
          edition = evaluator.edition || {title: evaluator.title, body: evaluator.body}
          create(evaluator.edition_factory, state, **edition, guide: guide)
        end
      end
    end
  end

  # guide communities should use the community_edition factory when creating
  # editions, as guide community editions don't have content owners.
  factory :guide_community, parent: :guide, class: GuideCommunity do
    transient do
      title "Example Guide Community"
      edition_factory :community_edition
    end
  end

  # points should use the summary_edition factory when creating editions, as
  # points have summaries.
  factory :point, parent: :guide, class: Point do
    transient do
      sequence :title do |n|
        "Point #{n}. Point Title"
      end
      edition_factory :summary_edition
    end
    slug "/service-manual/service-standard/#{SecureRandom.hex}"
  end

  # ----- Legacy Shortcuts

  factory :draft_guide, parent: :guide

  factory :review_requested_guide, parent: :guide, traits: [:with_review_requested_edition]
  factory :ready_guide, parent: :guide, traits: [:with_ready_edition]

  factory :published_guide, parent: :guide, traits: [:with_published_edition]
  factory :published_guide_community, parent: :guide_community, traits: [:with_published_edition]

  factory :unpublished_guide, parent: :guide, traits: [:has_been_unpublished]
  factory :unpublished_point, parent: :point, traits: [:has_been_unpublished]
end
