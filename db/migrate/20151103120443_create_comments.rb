class CreateComments < ActiveRecord::Migration[5.2]
  def self.up
    create_table :comments do |t|
      t.text :comment
      t.references :commentable, polymorphic: true
      t.references :user
      t.string :role, default: "comments"
      t.timestamps
    end

    add_index :comments, :commentable_type
  end

  def self.down
    drop_table :comments
  end
end
