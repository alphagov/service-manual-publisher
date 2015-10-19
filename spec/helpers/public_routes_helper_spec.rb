require 'rails_helper'

RSpec.describe PublicRoutesHelper do
  describe "#document_preview_url" do
    it "concatenates frontend host and document slug" do
      expect(Plek).to receive(:find).once.and_return("http://frontend-host.dev.gov.uk")
      guide = Guide.new(slug: "/guide/slug")

      expect(document_preview_url(guide)).to eq "http://frontend-host.dev.gov.uk/guide/slug"
    end
  end
end
