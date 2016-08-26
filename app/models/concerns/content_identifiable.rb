require 'active_support/concern'

module ContentIdentifiable
  extend ActiveSupport::Concern

  included do
    validates :content_id, presence: true, uniqueness: true

    before_validation on: :create do |object|
      object.content_id ||= SecureRandom.uuid
    end
  end
end
