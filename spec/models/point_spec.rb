require "rails_helper"

RSpec.describe Point do
  describe "#valid?" do
    describe "when validating the slug" do
      it "is valid for no topic to appear in the slug" do
        point = build(:point, slug: "/service-manual/an-excellent-point")
        expect(point).not_to be_valid
      end
    end

    describe "when validating the content owner" do
      it "is valid for the latest edition not to have a content owner" do
        edition = build(:edition, content_owner: nil)
        point = build(:guide_community, editions: [edition])
        expect(point).to be_valid
      end
    end
  end
end
