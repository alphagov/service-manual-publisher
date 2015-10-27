class ReviewRequest < ActiveRecord::Base
  has_many :editions
  has_many :approvals
end
