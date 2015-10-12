module AuthenticationHelpers
  def stub_user
    @stub_user ||= User.create!(uid: SecureRandom.hex)
  end

  def login_as_stub_user
    GDS::SSO.test_user = stub_user
  end
end

module AuthenticationControllerHelpers
  include AuthenticationHelpers

  def login_as(user)
    request.env['warden'] = double(
      authenticate!: true,
      authenticated?: true,
      user: user
    )
  end
end

RSpec.configure do |config|
  config.include AuthenticationControllerHelpers, type: :controller
  config.before(:each, type: :controller) do
    login_as_stub_user
  end

  config.include AuthenticationHelpers, type: :request
  config.before(:each, type: :request) do
    login_as_stub_user
  end
end
