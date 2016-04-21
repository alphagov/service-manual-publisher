class IndexForeignKeysInRedirects < ActiveRecord::Migration
  def change
    add_index :redirects, :content_id
  end
end
