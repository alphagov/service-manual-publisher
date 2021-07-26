class RemoveGuideIdFromSlugMigrations < ActiveRecord::Migration[5.2]
  def change
    remove_column :slug_migrations, :guide_id
  end
end
