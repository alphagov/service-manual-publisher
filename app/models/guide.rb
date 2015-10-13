class Guide < ActiveRecord::Base
  validates :content_id, presence: true, uniqueness: true

  has_many :editions
  has_one :latest_edition, -> { order(created_at: :desc) }, class_name: "Edition"

  accepts_nested_attributes_for :latest_edition

  PUBLISHERS = {
    "Design Community" => "https://designpatterns.hackpad.com"
  }

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end
end
