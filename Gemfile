source 'https://rubygems.org'

gem 'rails', '4.2.4'
gem 'pg', '~> 0.18'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

gem 'unicorn', '~> 4.9.0'
gem 'logstasher', '0.6.2'
gem 'plek', '~> 1.10'
gem 'airbrake', '~> 4.2.1'

gem 'govuk_admin_template', '~> 3.5.0'

gem 'gds-sso', '~> 11.0.0'
# Awaiting release of https://github.com/alphagov/gds-api-adapters/pull/413
gem 'gds-api-adapters', git: "https://github.com/alphagov/gds-api-adapters", ref: "cf3251"
gem 'govspeak', '~> 3.4.0'
gem 'kaminari', '~> 0.16.3'
gem 'acts_as_commentable', '~> 4.0.2'
gem 'active_link_to', '~> 1.0.3'
gem 'select2-rails', '~> 4.0.0'
gem 'diffy', '~> 3.0', '>= 3.0.7'
gem 'redcarpet', '~> 3.3.3'
gem 'rummageable', '1.2.0'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
end

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.3'
  gem 'simplecov', '0.10.0', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'pry'
  gem 'pry-nav'
  gem 'govuk-content-schema-test-helpers', '~> 1.3.0'
end

group :test do
  gem 'capybara'
  gem 'launchy'
end
