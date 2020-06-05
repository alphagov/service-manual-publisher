class RemoveTopicEmailSignup < ActiveRecord::Migration[5.2]
  def up
    remove_column :topics, :email_alert_signup_content_id
  end
end
