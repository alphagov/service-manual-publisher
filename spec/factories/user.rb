FactoryBot.define do
  factory :user do
    name { "Test User" }
    permissions { %w(signin) }
    email { "test-user@example.com" }
  end
end
