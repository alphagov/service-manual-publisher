RSpec.describe "/healthcheck" do
  it "returns database connection status" do
    get "/healthcheck"
    json = JSON.parse(response.body)

    expect(json["checks"]).to include("database_connectivity")
  end
end
