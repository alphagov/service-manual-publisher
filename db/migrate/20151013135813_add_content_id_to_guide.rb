class AddContentIdToGuide < ActiveRecord::Migration
  def change
    add_column :guides, :content_id, :string, index: true
  end
end
