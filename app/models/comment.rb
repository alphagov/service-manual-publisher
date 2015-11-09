class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  scope :for_rendering, ->{ order(created_at: :asc).includes(:user) }
end
