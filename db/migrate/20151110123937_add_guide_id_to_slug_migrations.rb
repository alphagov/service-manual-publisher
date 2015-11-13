class AddGuideIdToSlugMigrations < ActiveRecord::Migration
  def change
    add_column :slug_migrations, :guide_id, :integer
  end
end
