class RemoveReasonForChangeFromEditions < ActiveRecord::Migration
  def change
    remove_column :editions, :reason_for_change, :text
  end
end
