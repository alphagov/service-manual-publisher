FactoryGirl.define do
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

  # ---

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
end
