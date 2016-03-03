FactoryGirl.define do
  factory :guide_community do
    latest_edition { build(:edition, content_owner: nil) }
    slug "/service-manual/test-guide#{SecureRandom.hex}"
  end

  factory :guide do
    latest_edition { build(:edition) }
    slug "/service-manual/test-guide#{SecureRandom.hex}"
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

  factory :draft_guide, parent: :guide do
    latest_edition { build(:edition, state: "draft") }
  end

  factory :review_requested_guide, parent: :guide do
    latest_edition { build(:edition, state: "review_requested") }
  end

  factory :published_guide, parent: :guide do
    latest_edition { build(:edition, state: "published") }
  end

  factory :approved_guide, parent: :guide do
    latest_edition { build(:edition, state: "approved") }
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
  end

  factory :published_edition, parent: :edition do
    state "published"
  end

  factory :approved_edition, parent: :edition do
    state "approved"
  end

  factory :review_requested_edition, parent: :edition do
    state "review_requested"
  end
end

