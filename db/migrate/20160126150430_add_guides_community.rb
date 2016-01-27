class AddGuidesCommunity < ActiveRecord::Migration
  def change
    add_column :guides, :community, :boolean, default: false
  end
end
