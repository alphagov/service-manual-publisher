class RemoveNotNullConstraintsFromContentOwners < ActiveRecord::Migration
  def change
    change_column :content_owners, :href, :string, null: true
    change_column :content_owners, :title, :string, null: true
  end
end
