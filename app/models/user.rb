class User < ActiveRecord::Base
  include GDS::SSO::User

  validates_presence_of :email, on: :create, message: "can't be blank"
end
