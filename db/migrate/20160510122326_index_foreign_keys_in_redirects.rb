class IndexForeignKeysInRedirects < ActiveRecord::Migration[5.2]
  def change
    add_index :redirects, :content_id
  end
end
