FactoryGirl.define do
  factory :guide_community do
    latest_edition { build(:community_edition, content_owner: nil) }
    slug "/service-manual/topic-name/test-guide#{SecureRandom.hex}"
  end

  factory :guide do
    latest_edition { build(:edition) }
    slug "/service-manual/topic-name/test-guide#{SecureRandom.hex}"
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
    content_owner { build(:guide_community) }
    user { build(:user) }
  end

  factory :community_edition, parent: :edition do
    sequence :title do |n|
      "#{n} Community"
    end
  end

  factory :draft_guide, parent: :guide do
    latest_edition { build(:edition, state: "draft") }
  end

  factory :review_requested_guide, parent: :guide do
    latest_edition { build(:edition, state: "review_requested") }
  end

  factory :published_guide, parent: :guide do
    latest_edition { build(:edition, state: "published") }
  end

  factory :ready_guide, parent: :guide do
    latest_edition { build(:edition, state: "ready") }
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

