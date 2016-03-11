class CreateCheckedUrls < ActiveRecord::Migration
  def change
    create_table :checked_urls do |t|
      t.text :url, null: false
      t.boolean :ok, null: false
      t.timestamps
    end
  end
end
