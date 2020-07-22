class User < ApplicationRecord
  include GDS::SSO::User

  has_many :editions, foreign_key: :author_id

  def self.authors
    User.joins(:editions).distinct
  end
end
