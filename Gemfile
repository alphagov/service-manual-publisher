source 'https://rubygems.org'

gem 'rails', '4.2.7.1'
gem 'pg'
gem 'sass-rails'
gem 'uglifier'

gem 'unicorn'
gem 'logstasher'
gem 'plek'
# We pin airbrake because we tried to upgrade to version 5 and failed to deploy it
# in staging. The gem complained about a configuration error when precompiling the
# asserts. Here is the attempt:
# https://github.com/alphagov/service-manual-publisher/commit/ae7f0f1016d84f71282adfac3640c00047115ebe
gem 'airbrake', '~> 4.2.1'

gem 'govuk_admin_template'

gem 'gds-sso'
gem 'gds-api-adapters'
gem 'govspeak'
gem 'kaminari'
gem 'active_link_to'
gem 'select2-rails'
gem 'diffy'
gem 'redcarpet'
gem 'auto_strip_attributes'
gem 'rinku', require: "rails_rinku"

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
end

group :development, :test do
  gem 'byebug'
  gem 'govuk-lint'
  gem 'jasmine'
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-nav'
  gem 'rspec-rails'
  gem 'fuubar'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'govuk-content-schema-test-helpers'
  gem 'webmock'
end
