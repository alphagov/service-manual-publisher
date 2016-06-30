require 'rails_helper'

RSpec.describe GuideManager, '#request_review!' do
  it "creates a new edition with a state of 'review_requested'" do
    user = create(:user)
    guide = create_guide

    manager = described_class.new(guide: guide, user: user)
    manager.request_review!

    expect(guide.latest_edition.state).to eq('review_requested')
  end

  it "creates a new edition created by the supplied user" do
    user = create(:user)
    guide = create_guide

    manager = described_class.new(guide: guide, user: user)
    manager.request_review!

    expect(guide.latest_edition.created_by).to eq(user)
  end

  def create_guide
    editions = [
      build(:edition, title: 'Agile')
    ]
    create(:guide, :with_topic_section, editions: editions)
  end
end

RSpec.describe GuideManager, '#approve_for_publication!' do
  it "creates a new edition with a state of 'ready'" do
    user = create(:user)
    guide = create_guide

    manager = described_class.new(guide: guide, user: user)
    manager.approve_for_publication!

    expect(guide.latest_edition.state).to eq('ready')
  end

  it "creates a new edition created by the supplied user" do
    user = create(:user)
    guide = create_guide

    manager = described_class.new(guide: guide, user: user)
    manager.approve_for_publication!

    expect(guide.latest_edition.created_by).to eq(user)
  end

  it "delivers a notification" do
    user = create(:user)
    guide = create_guide

    manager = described_class.new(guide: guide, user: user)
    manager.approve_for_publication!

    expect(
      ActionMailer::Base.deliveries.last.subject
    ).to include("ready for publishing")
  end

  def create_guide
    editions = [
      build(:edition, title: 'Agile'),
      build(:edition, title: 'Agile', state: 'review_requested')
    ]
    create(:guide, :with_topic_section, editions: editions)
  end
end

RSpec.describe GuideManager, '#publish' do
  it "creates a new edition with a state of 'published'" do
    expect(PUBLISHING_API).to receive(:publish)
    expect(RUMMAGER_API).to receive(:add_document)

    user = create(:user)
    guide = create_guide

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    expect(guide.latest_edition.state).to eq('published')
  end

  it "creates a new edition created by the supplied user" do
    expect(PUBLISHING_API).to receive(:publish)
    expect(RUMMAGER_API).to receive(:add_document)

    user = create(:user)
    guide = create_guide

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    expect(guide.latest_edition.created_by).to eq(user)
  end

  it "delivers a notification" do
    expect(PUBLISHING_API).to receive(:publish)
    expect(RUMMAGER_API).to receive(:add_document)

    user = create(:user)
    guide = create_guide

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    expect(
      ActionMailer::Base.deliveries.last.subject
    ).to include("has been published")
  end

  it "is successful" do
    expect(PUBLISHING_API).to receive(:publish)
    expect(RUMMAGER_API).to receive(:add_document)

    user = create(:user)
    guide = create_guide

    manager = described_class.new(guide: guide, user: user)
    result = manager.publish

    expect(result).to be_success
  end

  it "saves and publishes the service standard with other published points if publishing a point" do
    user = create(:user)

    other_edition = create(:edition, title: "Scrum", description: "This is a description", state: "published")
    create(:point, editions: [other_edition])

    editions = [
      build(:edition, title: 'Agile', description: "Summary"),
      build(:edition, title: 'Agile', description: "Summary", state: 'review_requested'),
      build(:edition, title: 'Agile', description: "Summary", state: 'ready')
    ]
    point = create(:point, editions: editions)

    expect(PUBLISHING_API).to receive(:publish)
      .with(point.content_id, an_instance_of(String))
      .once

    expect(PUBLISHING_API).to receive(:put_content)
      .with(
        an_instance_of(String),
        hash_including(
          details: hash_including(
            points: [
              hash_including(:base_path, :summary, title: "Scrum"),
              hash_including(:base_path, :summary, title: "Agile"),
            ]
          )
        )
      )
      .once

    expect(PUBLISHING_API).to receive(:publish)
      .with(ServiceStandardPresenter::SERVICE_STANDARD_CONTENT_ID, "major")
      .once

    expect(RUMMAGER_API).to receive(:add_document)

    manager = described_class.new(guide: point, user: user)
    manager.publish
  end

  context "when communication with the publishing api fails" do
    it "doesn't create anything" do
      stub_publishing_api_to_fail

      user = create(:user)
      guide = create_guide

      manager = described_class.new(guide: guide, user: user)
      manager.publish

      expect(guide.editions.published).to be_empty
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it "is not successful and has an error" do
      stub_publishing_api_to_fail

      user = create(:user)
      guide = create_guide

      manager = described_class.new(guide: guide, user: user)
      result = manager.publish

      expect(result).to_not be_success
      expect(result.errors).to include('trouble')
    end

    def stub_publishing_api_to_fail
      gds_api_exception = GdsApi::HTTPErrorResponse.new(
        422,
                            'https://some-service.gov.uk',
                            'error' => { 'message' => 'trouble' }
      )
      expect(PUBLISHING_API).to receive(:publish).and_raise(gds_api_exception)
    end
  end

  def create_guide
    editions = [
      build(:edition, title: 'Agile'),
      build(:edition, title: 'Agile', state: 'review_requested'),
      build(:edition, title: 'Agile', state: 'ready')
    ]
    create(:guide, :with_topic_section, editions: editions)
  end
end

RSpec.describe GuideManager, '#discard_draft' do
  context "without published editions" do
    it "destroys the guide and all editions" do
      expect(PUBLISHING_API).to receive(:discard_draft)

      user = create(:user)
      guide = create_guide

      manager = described_class.new(guide: guide, user: user)
      manager.discard_draft

      guide_id = guide.id
      expect(Guide.find_by_id(guide_id)).to eq(nil)
      expect(Edition.where(guide_id: guide_id).count).to eq(0)
    end

    it "is successful" do
      expect(PUBLISHING_API).to receive(:discard_draft)

      user = create(:user)
      guide = create_guide

      manager = described_class.new(guide: guide, user: user)
      result = manager.discard_draft

      expect(result).to be_success
    end

    def create_guide
      editions = [
        build(:edition, title: 'Agile')
      ]
      create(:guide, :with_topic_section, editions: editions)
    end
  end

  context "with published editions" do
    it "destroys just the editions since the last published edition" do
      expect(PUBLISHING_API).to receive(:discard_draft)

      user = create(:user)
      guide = create_guide

      manager = described_class.new(guide: guide, user: user)
      manager.discard_draft

      expect(guide.editions.where(title: 'Agile').count).to eq(4)
      expect(guide.latest_edition.state).to eq('published')
      expect(guide.editions.where(title: 'Agile amended')).to be_empty
    end

    def create_guide
      editions = [
        build(:edition, title: 'Agile'),
        build(:edition, title: 'Agile', state: 'review_requested'),
        build(:edition, title: 'Agile', state: 'ready'),
        build(:edition, title: 'Agile', state: 'published'),
        build(:edition, title: 'Agile amended'),
        build(:edition, title: 'Agile amended', state: 'review_requested'),
      ]
      create(:guide, :with_topic_section, editions: editions)
    end
  end

  context 'when communication with the publishing api fails' do
    it "doesn't destroy anything if communication with the publishing api fails" do
      stub_publishing_api_to_fail

      user = create(:user)
      editions = [
        build(:edition, title: 'Agile')
      ]
      guide = create(:guide, :with_topic_section, editions: editions)

      manager = described_class.new(guide: guide, user: user)
      manager.discard_draft

      expect(Guide.find_by_id(guide.id)).to be_present
    end

    def stub_publishing_api_to_fail
      gds_api_exception = GdsApi::HTTPErrorResponse.new(
        422,
                            'https://some-service.gov.uk',
                            'error' => { 'message' => 'trouble' }
      )
      expect(PUBLISHING_API).to receive(:discard_draft).and_raise(gds_api_exception)
    end
  end
end
