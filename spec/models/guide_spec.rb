require 'rails_helper'

RSpec.describe Guide do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      edition = Generators.valid_edition(title: "something", state: "published")
      guide = Guide.create!(slug: "/slug", content_id: nil, latest_edition: edition)
      expect(guide.content_id).to be_present
    end
  end
end
