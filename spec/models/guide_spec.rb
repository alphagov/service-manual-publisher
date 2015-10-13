require 'rails_helper'

describe Guide do
  describe "on create callbacks" do
    it "generates and sets content_id on create" do
      guide = Guide.create(content_id: nil)
      expect(guide.content_id).to be_present
    end
  end
end
