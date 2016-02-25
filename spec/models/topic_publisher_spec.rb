require 'rails_helper'

RSpec.describe TopicPublisher do
  context "when a guide is of state 'draft'" do
    let(:topic) do
    end

    describe "#put_draft" do
      it "sends draft payload to publishing API" do
        publisher = described_class.new(Topic.new(content_id: "content-id-hello"))

        expect_any_instance_of(TopicPresenter).to receive(:content_payload).and_return(nice: 'payload')

        expect_any_instance_of(GdsApi::PublishingApiV2).to receive(:put_content).with("content-id-hello", { nice: 'payload' }).and_return(true)

        publisher.put_draft
      end
    end
  end

  describe "#publish" do
    it "publishes the latest edition via publishing API" do
      publisher = described_class.new(Topic.new(content_id: "content-id-hello"))

      expect_any_instance_of(GdsApi::PublishingApiV2).to receive(:publish).with("content-id-hello", "minor").and_return(true)

      publisher.publish
    end

    it "indexes the topic in rummager" do
      topic = Topic.new(content_id: "content-id-hello", title: "Test Topic")
      publisher = described_class.new(topic)
      indexer_double = double(:indexer)
      allow_any_instance_of(GdsApi::PublishingApiV2).to receive(:publish).with("content-id-hello", "minor").and_return(true)
      expect(TopicSearchIndexer).to receive(:new).with(anything).and_return(indexer_double)
      expect(indexer_double).to receive(:index)
      publisher.index_for_search
    end
  end

  describe "#put_links" do
    it "puts links for the topic" do
      publisher = described_class.new(Topic.new(content_id: "content-id-hello"))

      expect_any_instance_of(TopicPresenter).to receive(:links_payload).and_return(links: { linked_items: [] })

      expect_any_instance_of(GdsApi::PublishingApiV2).to receive(:put_links).with("content-id-hello", links: { linked_items: [] }).and_return(true)

      publisher.put_links
    end

    it "asynchronously tags linked items to the topic" do
      allow_any_instance_of(GdsApi::PublishingApiV2).to receive(:put_links)

      publisher = described_class.new(Topic.new(content_id: "topic-content-id"))
      expect_any_instance_of(TopicPresenter).to receive(:links_payload).and_return(links: { linked_items: ['guide-1-content-id', 'guide-1-content-id'] })
      expect(GuideTaggerJob).to receive(:perform_later).twice

      publisher.put_links
    end
  end
end
