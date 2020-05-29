class User < ApplicationRecord
  include GDS::SSO::User

  validates :email, presence: { on: :create, message: "can't be blank" }

  has_many :editions, foreign_key: :author_id

  def self.authors
    User.joins(:editions).distinct
  end
end
