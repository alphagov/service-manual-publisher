require "rails_helper"

RSpec.describe TopicPublisher, "#save_draft" do
  let :topic_section do
    topic = create(:topic)
    create(:topic_section, topic: topic)
  end

  it "persists the content model and returns a successful response" do
    topic = create(:topic)
    publishing_api = double(:publishing_api)
    allow(publishing_api).to receive(:put_content)
    allow(publishing_api).to receive(:patch_links)

    publication_response =
      described_class.new(topic: topic, publishing_api: publishing_api)
        .save_draft

    expect(topic).to be_persisted
    expect(publication_response).to be_success
  end

  it "sends the draft and the links to the publishing api" do
    topic = create(:topic)
    publishing_api = double(:publishing_api)

    expect(publishing_api).to receive(:put_content)
      .with(topic.content_id, a_hash_including(base_path: topic.path))
    expect(publishing_api).to receive(:patch_links)
      .with(topic.content_id, a_kind_of(Hash))

    described_class.new(topic: topic, publishing_api: publishing_api)
      .save_draft
  end

  it "does not send the draft to the publishing api if the content model is not valid"\
    " and returns an unsuccessful response" do
    create(:topic, path: "/service-manual/topic")
    topic = create(:topic, path: "/service-manual/blah")

    allow(topic).to receive(:valid?) { false }

    publishing_api = double(:publishing_api)

    expect(publishing_api).to_not receive(:put_content)

    publication_response =
      described_class.new(topic: topic, publishing_api: publishing_api)
        .save_draft

    expect(publication_response).to_not be_success
  end

  context "when the publishing api call fails" do
    let(:publishing_api_which_always_fails) do
      api = double(:publishing_api)
      gds_api_exception = GdsApi::HTTPErrorResponse.new(
        422,
        "https://some-service.gov.uk",
        "error" => { "message" => "trouble" },
      )
      allow(api).to receive(:put_content).and_raise(gds_api_exception)
      api
    end

    it "does not persist the content model and returns an unsuccessful response" do
      topic = build(:topic)

      publication_response =
        described_class.new(topic: topic, publishing_api: publishing_api_which_always_fails)
          .save_draft

      expect(topic).to be_new_record
      expect(publication_response).to_not be_success
    end

    it "returns the gds api error messages" do
      topic = build(:topic)

      publication_response =
        described_class.new(topic: topic, publishing_api: publishing_api_which_always_fails)
          .save_draft

      expect(publication_response.error).to include("trouble")
    end
  end
end

RSpec.describe TopicPublisher, "#publish" do
  it "sends the draft to the publishing api" do
    publishing_api = double(:publishing_api)
    topic = create(:topic)

    expect(publishing_api).to receive(:publish)
      .once.with(topic.content_id)

    described_class.new(topic: topic, publishing_api: publishing_api)
      .publish
  end
end
