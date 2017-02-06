class Redirect < ApplicationRecord
  include ContentIdentifiable

  validates :old_path, presence: true
  validates :new_path, presence: true
end
