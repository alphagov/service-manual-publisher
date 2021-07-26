class AddContentIdToSlugMigrations < ActiveRecord::Migration[5.2]
  def change
    add_column :slug_migrations, :content_id, :string, index: true, null: false
  end
end
