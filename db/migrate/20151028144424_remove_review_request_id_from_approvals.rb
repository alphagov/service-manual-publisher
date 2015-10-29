class RemoveReviewRequestIdFromApprovals < ActiveRecord::Migration
  def change
    remove_column :approvals, :review_request_id, :integer
  end
end
