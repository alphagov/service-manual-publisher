class RemoveContentOwnerNotNullConstraintFromEditions < ActiveRecord::Migration[5.2]
  def change
    change_column_null :editions, :content_owner_id, true
  end
end
