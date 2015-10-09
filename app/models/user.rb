class User < ActiveRecord::Base
  include GDS::SSO::User
end
