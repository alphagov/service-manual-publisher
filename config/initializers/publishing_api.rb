require "gds_api/publishing_api"

PUBLISHING_API = GdsApi::PublishingApi.new(
  Plek.find("publishing-api"),
  bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
)
