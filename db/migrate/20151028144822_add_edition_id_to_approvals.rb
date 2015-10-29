class AddEditionIdToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :edition_id, :integer
  end
end
