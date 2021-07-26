class AddTypeToGuides < ActiveRecord::Migration[5.2]
  def change
    add_column :guides, :type, :string
  end
end
