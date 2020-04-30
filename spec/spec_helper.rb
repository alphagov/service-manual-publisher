require "capybara/rspec"
require "webmock/rspec"

require "plek"
require "gds_api/test_helpers/publishing_api"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include GdsApi::TestHelpers::PublishingApi
end
