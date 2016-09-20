class AddEmailAlertSignupContentIdsToTopics < ActiveRecord::Migration

  class FakeTopic < ActiveRecord::Base
    self.table_name = 'topics'
  end

  def change
    add_column :topics, :email_alert_signup_content_id, :string
    add_index :topics, :email_alert_signup_content_id, unique: true

    FakeTopic.all.each do |topic|
      topic.update_attribute(:email_alert_signup_content_id, SecureRandom.uuid)
    end
  end
end
