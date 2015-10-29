class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.references :user
      t.references :edition
    end
  end
end
