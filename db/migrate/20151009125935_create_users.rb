class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :uid, index: true
      t.text :name
      t.text :email, index: true
      t.text :organisation_slug
      t.text :organisation_content_id, index: true
      t.boolean :remotely_signed_out, default: false
      t.boolean :disabled, default: false
      t.text :permissions, array: true

      t.timestamps null: false
    end
  end
end
