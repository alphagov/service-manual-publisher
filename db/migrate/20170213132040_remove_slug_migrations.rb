class RemoveSlugMigrations < ActiveRecord::Migration[5.0]
  def up
    drop_table :slug_migrations
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
