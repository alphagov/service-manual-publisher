class RemoveReasonForChangeFromEditions < ActiveRecord::Migration[5.2]
  def change
    remove_column :editions, :reason_for_change, :text
  end
end
