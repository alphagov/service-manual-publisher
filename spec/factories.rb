FactoryGirl.define do
  factory :guide_community do
    slug "/service-manual/topic-name/test-guide#{SecureRandom.hex}"

    editions {
      [ build(:community_edition, content_owner: nil) ]
    }
  end

  factory :guide do
    transient do
      title "Example Guide"
    end
    slug "/service-manual/topic-name/test-guide#{SecureRandom.hex}"

    trait :with_draft_edition do
      editions {
        [ build(:edition, title: title) ]
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
  end

  factory :community_edition, parent: :edition do
    sequence :title do |n|
      "#{n} Community"
    end
  end

  factory :draft_guide, parent: :guide do
    editions {
      [ build(:edition, state: "draft") ]
    }
  end

  factory :review_requested_guide, parent: :guide do
    editions {
      [ build(:edition, state: "review_requested") ]
    }
  end

  factory :ready_guide, parent: :guide do
    editions {
      [ build(:edition, state: "ready") ]
    }
  end

  factory :published_guide, parent: :guide do
    transient do
      title "Example Guide"
      body "The quick brown fox jumped over the lazy dog."
    end

    editions { [
      build(:edition, state: "draft", title: title, body: body),
      build(:edition, state: "review_requested", title: title, body: body),
      build(:edition, state: "ready", title: title, body: body),
      build(:edition, state: "published", title: title, body: body),
      ] }
  end

  factory :published_guide_community, parent: :published_guide, class: 'GuideCommunity'

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
      tree do
        guide1 = create(:published_guide)
        guide2 = create(:published_guide)
        [
          {
            title: "Group 1 title",
            guides: [guide1.to_param],
            description: "Group 1 description",
          },
          {
            title: "Group 2",
            guides: [guide2.to_param],
            description: "Group 2 description",
          }
        ]
      end
    end
  end

  factory :draft_edition, parent: :edition do
  end

  factory :published_edition, parent: :edition do
    state "published"
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
end

