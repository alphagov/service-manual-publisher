class DropCheckedUrls < ActiveRecord::Migration
  def change
    drop_table :checked_urls
  end
end
