class AddTypeToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :type, :string
  end
end
