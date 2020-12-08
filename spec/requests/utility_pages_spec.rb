require "rails_helper"

RSpec.describe "utility pages", type: :request do
  it "should respond with 200 to /style-guide" do
    get "/style-guide"

    expect(response).to have_http_status(:ok)
  end
end
