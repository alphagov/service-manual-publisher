class DropContentOwners < ActiveRecord::Migration
  def change
    drop_table :content_owners
  end
end
