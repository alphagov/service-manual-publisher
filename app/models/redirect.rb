class Redirect < ActiveRecord::Base
  include ContentIdentifiable

  validates :old_path, presence: true
  validates :new_path, presence: true

  HUMANIZED_ATTRIBUTES = {
    old_path: 'Redirect source',
    new_path: 'Redirect destination'
  }

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

end
