class CreateTopicSection < ActiveRecord::Migration
  def change
    create_table :topic_sections do |t|
      t.integer :topic_id, null: false
      t.string :title
      t.string :description
      t.integer :position, null: false
      t.timestamps
    end
  end
end
