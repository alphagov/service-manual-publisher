class RemoveReviewRequests < ActiveRecord::Migration
  def change
    drop_table :review_requests
  end
end
