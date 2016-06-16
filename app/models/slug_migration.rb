require 'gds_api/rummager'

class SlugMigration < ActiveRecord::Base
  validates :slug, uniqueness: true
  validates :redirect_to, presence: true
  validate :is_not_already_completed
  validate :redirect_to_is_not_slug

  before_save do |object|
    object.content_id = SecureRandom.uuid
  end

private

  def is_not_already_completed
    errors.add(:base, "is completed and can not be modified") if completed_was
  end

  def redirect_to_is_not_slug
    if redirect_to == slug
      errors.add(:redirect_to, "must not be the same as slug")
    end
  end
end
