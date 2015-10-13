class RemoveTitleFromGuide < ActiveRecord::Migration
  def change
    remove_column :guides, :title
  end
end
