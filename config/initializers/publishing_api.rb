require "gds_api/publishing_api_v2"

PUBLISHING_API = GdsApi::PublishingApiV2.new(
  Plek.new.find("publishing-api"),
  bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
)
