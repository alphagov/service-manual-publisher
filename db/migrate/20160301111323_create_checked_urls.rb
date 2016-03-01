class CreateCheckedUrls < ActiveRecord::Migration
  def change
    create_table :checked_urls do |t|
      t.string :url, null: false
      t.integer :code, null: false
      t.timestamps
    end
  end
end
