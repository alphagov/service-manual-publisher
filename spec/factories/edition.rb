FactoryGirl.define do

  # Example Usage
  # 
  # create(:edition, :draft, title: "A Draft Edition")
  # create(:community_edition, :published, title: "A Published Community Edition")
  # 
  # Legacy Usage:
  # create(:draft_edition)

  STATES = [:draft, :ready, :review_requested, :published, :unpublished].freeze

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

    # create traits for all STATES
    STATES.each do |state| 
      trait state do
        state state.to_s
      end
    end
  end

  # community editions do not have a content owner
  factory :community_edition, parent: :edition do
    content_owner nil
    sequence :title do |n|
      "#{n} Community"
    end
  end

  # summary editions also need a summary
  factory :summary_edition, parent: :edition do
    summary "Description"
  end

  # Create *legacy* draft_edition, ready_edition [..,] unpublished_edition
  # factories. These should be phased out in favour of traits
  
  STATES.each do |state|
    factory "#{state}_edition".to_sym, parent: :edition, traits: [state]
  end

end
