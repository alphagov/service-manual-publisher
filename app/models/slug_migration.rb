class SlugMigration < ActiveRecord::Base
  validates :slug, uniqueness: true
end
