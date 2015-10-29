class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.references :review_request
      t.references :user
    end
  end
end
