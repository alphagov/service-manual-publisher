require "rails_helper"

RSpec.describe Republisher do
  describe "#republish" do
    let(:presenter) do
      double(
        :presenter,
        content_payload: "payload",
        links_payload: { links: "links" },
        content_id: "content_id",
      )
    end

    it "updates and publishes the content" do
      put_content_request = stub_publishing_api_put_content("content_id", "payload".to_json)
      publish_request = stub_publishing_api_publish("content_id", update_type: "republish")

      patch_links_request = stub_publishing_api_patch_links(
        "content_id",
        { links: "links", bulk_publishing: true },
      )

      described_class.new.call(presenter)
      expect(put_content_request).to have_been_requested
      expect(patch_links_request).to have_been_requested
      expect(publish_request).to have_been_requested
    end

    it "supports changing the update type" do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      publish_request = stub_publishing_api_publish("content_id", update_type: "minor")
      described_class.new.call(presenter, update_type: "minor")
      expect(publish_request).to have_been_requested
    end
  end
end
