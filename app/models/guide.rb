class Guide < ActiveRecord::Base
  has_many :editions
  has_one :latest_edition, -> { order(created_at: :desc) }, class_name: "Edition"

  accepts_nested_attributes_for :latest_edition
end
