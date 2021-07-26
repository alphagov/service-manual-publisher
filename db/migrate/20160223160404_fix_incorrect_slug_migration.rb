class FixIncorrectSlugMigration < ActiveRecord::Migration[5.2]
  def change
    old_slug = "/service-manual/service-manual/digital-foundation-day-training"
    new_slug = "/service-manual/digital-foundation-day-training"
    execute "UPDATE slug_migrations SET slug = '#{new_slug}' WHERE slug = '#{old_slug}'"
  end
end
