class ReviewRequest < ActiveRecord::Base
  has_many :editions
end
