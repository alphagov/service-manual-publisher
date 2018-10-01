require_relative 'boot'

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "action_mailer/railtie"
# require "active_job/railtie"
# require "active_storage/engine"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ServiceManualPublisher
  GDS_ORGANISATION_CONTENT_ID = 'af07d5a5-df63-4ddc-9383-6a666845ebe9'.freeze

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_record.schema_format = :sql
    config.action_mailer.default_url_options = { host: Plek.new.external_url_for("service-manual-publisher") }
  end
end
