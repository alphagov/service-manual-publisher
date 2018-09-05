FactoryBot.define do
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
  # -> create(:point, :has_been_pubished, edition: { created_by: bob })
  #
  # Create a guide where every edition belongs to a specific community
  # -> guide_community = create(:guide_community)
  #    create(:guide, edition: { content_owner_id: guide_community.id })
  #
  # Create a guide with manually defined editions
  # -> create(:guide, editions: [create(:edition)])

  factory :guide do
    transient do
      title { "Example Guide" }
      body { "The quick brown fox jumped over the lazy dog." }
      edition { nil }
      edition_factory { :edition }
      # a guide can't exist without an edition, so by default include one draft
      states { [:draft] }
      topic { nil }
      topic_section { nil }
      requires_topic { true }
    end

    slug { "/service-manual/topic-name/test-guide#{SecureRandom.hex}" }

    trait :with_draft_edition do
      # noop
    end

    trait :with_review_requested_edition do
      states { %i(draft review_requested) }
    end

    trait :with_ready_edition do
      states { %i(draft review_requested ready) }
    end

    trait :with_published_edition do
      transient do
        states { %i(draft review_requested ready published) }
      end
    end

    trait :with_previously_published_edition do
      transient do
        states { %i(draft review_requested ready published draft) }
      end
    end

    trait :has_been_unpublished do
      transient do
        states { %i(draft review_requested ready published unpublished) }
      end
    end

    after(:build) do |guide, evaluator|
      if evaluator.topic_section
        guide.topic_section_guides.build(topic_section: evaluator.topic_section)
      elsif evaluator.requires_topic
        topic_section = build(:topic_section, topic: evaluator.topic || build(:topic))
        guide.topic_section_guides.build(topic_section: topic_section)
      end
    end

    # once the guide has been built, create an edition of the right type for
    # every state the guide should have been in, passing through attributes in
    # edition.
    after(:build) do |guide, evaluator|
      if guide.editions.empty?
        evaluator.states.each do |state|
          edition_attributes = evaluator.edition || { title: evaluator.title, body: evaluator.body }
          guide.editions << create(evaluator.edition_factory, state, **edition_attributes, guide: guide)
        end
      end
    end
  end

  # guide communities should use the community_edition factory when creating
  # editions, as guide community editions don't have content owners.
  factory :guide_community, parent: :guide, class: GuideCommunity do
    transient do
      title { "Example Guide Community" }
      edition_factory { :community_edition }
    end
  end

  # points should use the summary_edition factory when creating editions, as
  # points have summaries.
  factory :point, parent: :guide, class: Point do
    transient do
      edition_factory { :point_edition }
      requires_topic { false }
      sequence :title do |n|
        "Point #{n}. Point Title"
      end
    end
    slug { "/service-manual/service-standard/#{SecureRandom.hex}" }
  end
end
