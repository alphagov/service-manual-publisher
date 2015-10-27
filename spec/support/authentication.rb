module AuthenticationHelpers
  def stub_user
    @stub_user ||= User.create!(uid: SecureRandom.hex, name: "User Name")
  end

  def login_as_stub_user
    GDS::SSO.test_user = stub_user
  end

  def login_as(user)
    if block_given?
      old_user = GDS::SSO.test_user
      GDS::SSO.test_user = user
      yield
      GDS::SSO.test_user = old_user
    else
      GDS::SSO.test_user = user
    end
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

  [:request, :feature].each do |spec_type|
    config.include AuthenticationHelpers, type: spec_type
    config.before(:each, type: spec_type) do
      login_as_stub_user
    end
  end
end
