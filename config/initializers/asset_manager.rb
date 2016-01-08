require 'gds_api/asset_manager'
require 'plek'

ASSET_API = GdsApi::AssetManager.new(
  Plek.current.find('asset-manager'),
  bearer_token: ENV['ASSET_MANAGER_BEARER_TOKEN'] || "12345678", # test and development environments accept any value
)
