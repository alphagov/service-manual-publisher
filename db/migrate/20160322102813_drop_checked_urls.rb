class DropCheckedUrls < ActiveRecord::Migration[5.2]
  def change
    drop_table :checked_urls
  end
end
