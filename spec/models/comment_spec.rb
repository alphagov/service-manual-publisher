require 'rails_helper'

RSpec.describe Comment, type: :model do
  it "requires :comment to be present" do
    comment = Comment.new(comment: nil)
    expect(comment).to be_invalid
    expect(comment.errors[:comment].size).to eq 1
  end
end
