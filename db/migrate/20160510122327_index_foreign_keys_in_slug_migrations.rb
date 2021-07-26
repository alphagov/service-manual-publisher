class IndexForeignKeysInSlugMigrations < ActiveRecord::Migration[5.2]
  def change
    add_index :slug_migrations, :content_id
  end
end
