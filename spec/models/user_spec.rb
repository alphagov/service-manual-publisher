require 'rails_helper'
require 'gds-sso/lint/user_spec'

RSpec.describe User, type: :model do
  it_behaves_like "a gds-sso user class"

  describe "#authors" do
    it "lists users who are authors" do
      author1 = create(:user, name: "Author 1")
      author2 = create(:user, name: "Author 2")
      user1 = create(:user, name: "User 1")
      user2 = create(:user, name: "User 2")
      create(:edition, author: author1)
      create(:edition, author: author2)

      expect(User.authors.to_a).to include author1
      expect(User.authors.to_a).to include author2
      expect(User.authors.to_a).to_not include user1
      expect(User.authors.to_a).to_not include user2
    end
  end
end
