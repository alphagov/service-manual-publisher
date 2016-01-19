class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  scope :for_rendering, ->{ order(created_at: :desc).includes(:user) }

  validates :comment, presence: true

  def html_id
    "comment-#{id}"
  end
end
