require "rails_helper"

RSpec.describe "utility pages", type: :request do
  it "should respond with 'OK' to /healthcheck" do
    get "/healthcheck"

    expect(response.status).to eq(200)
    expect(response.body).to eq("OK")
  end

  it "should respond with 200 to /style-guide" do
    get "/style-guide"

    expect(response.status).to eq(200)
  end
end
