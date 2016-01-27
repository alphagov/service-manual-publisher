class RemoveNotNullConstraintFromEditionsContentOwnerId < ActiveRecord::Migration
  def change
    change_column :editions, :content_owner_id, :integer, null: true
  end
end
