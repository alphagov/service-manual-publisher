FactoryBot.define do
  factory :user do
    name "Test User"
    permissions ["signin"]
    email "test-user@example.com"
  end
end
