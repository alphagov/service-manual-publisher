class RemoveReviewRequestId < ActiveRecord::Migration
  def change
    remove_column :editions, :review_request_id, :integer
  end
end
