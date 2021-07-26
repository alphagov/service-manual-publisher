class RemoveTitleFromGuide < ActiveRecord::Migration[5.2]
  def change
    remove_column :guides, :title, :text
  end
end
