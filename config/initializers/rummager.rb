require 'gds_api/rummager'

RUMMAGER_API =
  GdsApi::Rummager.new(Plek.new.find("search"))
