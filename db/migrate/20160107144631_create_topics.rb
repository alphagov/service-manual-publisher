class CreateTopics < ActiveRecord::Migration[5.2]
  def change
    create_table :topics do |t|
      t.timestamps
      t.string :path, null: false
      t.string :title, null: false
      t.string :description, null: false
      t.json :tree, null: false, default: {}
    end
  end
end
