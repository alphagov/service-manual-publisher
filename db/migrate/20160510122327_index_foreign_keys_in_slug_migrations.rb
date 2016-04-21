class IndexForeignKeysInSlugMigrations < ActiveRecord::Migration
  def change
    add_index :slug_migrations, :content_id
  end
end
