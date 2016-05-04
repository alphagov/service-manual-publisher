class AddTopicsVisuallyCollapsed < ActiveRecord::Migration
  def change
    add_column :topics, :visually_collapsed, :boolean, default: false
  end
end
