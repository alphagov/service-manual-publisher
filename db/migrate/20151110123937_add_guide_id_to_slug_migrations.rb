class AddGuideIdToSlugMigrations < ActiveRecord::Migration[5.2]
  def change
    add_column :slug_migrations, :guide_id, :integer
  end
end
