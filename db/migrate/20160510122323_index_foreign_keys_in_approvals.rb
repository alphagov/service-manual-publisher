class IndexForeignKeysInApprovals < ActiveRecord::Migration[5.2]
  def change
    add_index :approvals, :edition_id unless index_exists?(:approvals, :edition_id)
    add_index :approvals, :user_id unless index_exists?(:approvals, :user_id)
  end
end
