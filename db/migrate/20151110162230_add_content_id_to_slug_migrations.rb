class AddContentIdToSlugMigrations < ActiveRecord::Migration
  def change
    add_column :slug_migrations, :content_id, :string, index: true, null: false
  end
end
