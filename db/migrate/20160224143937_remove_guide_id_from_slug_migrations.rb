class RemoveGuideIdFromSlugMigrations < ActiveRecord::Migration
  def change
    remove_column :slug_migrations, :guide_id
  end
end
