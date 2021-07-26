class AddContentIdToGuide < ActiveRecord::Migration[5.2]
  def change
    add_column :guides, :content_id, :string, index: true
  end
end
