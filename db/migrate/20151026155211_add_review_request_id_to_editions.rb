class AddReviewRequestIdToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :review_request_id, :integer, index: true
  end
end
