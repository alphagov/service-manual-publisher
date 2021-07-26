class CreateSlugMigrations < ActiveRecord::Migration[5.2]
  def change
    create_table :slug_migrations do |t|
      t.string :slug
      t.boolean :completed, null: false, default: false

      t.timestamps null: false

      t.index :slug, unique: true
    end
  end
end
