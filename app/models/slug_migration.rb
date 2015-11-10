class SlugMigration < ActiveRecord::Base
  belongs_to :guide

  validates :slug, uniqueness: true
  validate :guide, :guide_must_be_nil_or_published
  validate :guide, :guide_cant_be_empty_when_migrating

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end

  def guide_must_be_nil_or_published
    if guide && !guide.editions.where(state: "published").any?
      errors.add(:guide, "must have a published edition")
    end
  end

  def guide_cant_be_empty_when_migrating
    if completed? && guide.nil?
      errors.add(:guide, "must not be blank")
    end
  end
end
