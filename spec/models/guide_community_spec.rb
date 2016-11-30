require 'rails_helper'

RSpec.describe GuideCommunity do
  describe "#valid?" do
    describe "when validating the content owner" do
      it "is valid for the latest edition not to have a content owner" do
        edition = build(:edition, content_owner: nil)
        point = build(:guide_community, editions: [edition])
        expect(point).to be_valid
      end
    end
  end
end
