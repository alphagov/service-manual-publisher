class CheckedUrl < ActiveRecord::Base
  def expired?
    created_at < 5.minutes.ago
  end
end
