class AddTopicsVisuallyCollapsed < ActiveRecord::Migration[5.2]
  def change
    add_column :topics, :visually_collapsed, :boolean, default: false
  end
end
