class SlugMigration < ActiveRecord::Base
  belongs_to :guide

  validates :slug, uniqueness: true
  validate :guide, :guide_must_be_nil_or_published

  def guide_must_be_nil_or_published
    if guide && !guide.editions.where(state: "published").any?
      errors.add(:guide, "must have a published edition")
    end
  end
end
