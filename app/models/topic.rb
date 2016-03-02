class Topic < ActiveRecord::Base
  include ContentIdentifiable
  validate :path_can_be_set_once
  validate :path_format

  def ready_to_publish?
    persisted?
  end

  private

  def path_can_be_set_once
    if persisted? && path != path_was
      errors.add(:path, "can not be changed")
    end
  end

  def path_format
    if !path.to_s.match(/\A\/service-manual\//)
      errors.add(:path, "must be present and start with '/service-manual/'")
    elsif !path.to_s.match(/\A\/service-manual\/[a-z0-9\-\/]+$/i)
      errors.add(:path, "can only contain letters, numbers and dashes")
    end
  end
end
