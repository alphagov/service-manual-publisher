RSpec.describe "/healthcheck" do
  before do
    get "/healthcheck"
  end

  it "returns a 200 HTTP status" do
    expect(response).to have_http_status(:ok)
  end

  it "returns database connection status" do
    json = JSON.parse(response.body)

    expect(json["checks"]).to include("database_connectivity")
  end
end
