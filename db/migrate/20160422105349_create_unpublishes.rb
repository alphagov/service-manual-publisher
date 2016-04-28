class CreateUnpublishes < ActiveRecord::Migration
  def change
    create_table :unpublishes do |t|
      t.text :content_id, null: false
      t.text :old_path, null: false
      t.text :new_path, null: false
      t.timestamps
    end
  end
end
