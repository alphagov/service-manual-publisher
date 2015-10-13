class Guide < ActiveRecord::Base
  has_many :editions

  def latest_edition
    editions.order(created_at: :desc).first
  end
end
