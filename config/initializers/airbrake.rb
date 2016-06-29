if ENV['ERRBIT_API_KEY'].present?
  errbit_uri = Plek.find_uri('errbit')

  Airbrake.configure do |config|
    config.project_id = ENV['ERRBIT_API_KEY']
    config.project_key = ENV['ERRBIT_API_KEY']
    config.host = errbit_uri.host
    config.environment = ENV['ERRBIT_ENVIRONMENT_NAME']
  end
end
