class RemoveContentOwnerNotNullConstraintFromEditions < ActiveRecord::Migration
  def change
    change_column_null :editions, :content_owner_id, true
  end
end
