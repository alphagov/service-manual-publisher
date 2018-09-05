FactoryBot.define do
  factory :slug_migration do
    slug { "/something" }

    trait :completed do
      completed { true }
    end

    trait :not_completed do
      completed { false }
    end

    trait :with_redirect_to do
      redirect_to { "/path-to-redirect-to" }
    end
  end
end
