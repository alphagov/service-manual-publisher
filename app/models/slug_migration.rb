class SlugMigration < ActiveRecord::Base
  validates :slug, uniqueness: true
  belongs_to :guide
end
