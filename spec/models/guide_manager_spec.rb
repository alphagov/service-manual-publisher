require 'rails_helper'

RSpec.describe GuideManager, '#request_review!' do
  it "creates a new edition with a state of 'review_requested'" do
    user = create(:user)
    guide = create(:guide)

    manager = described_class.new(guide: guide, user: user)
    manager.request_review!

    expect(guide.latest_edition.state).to eq('review_requested')
  end

  it "creates a new edition created by the supplied user" do
    user = create(:user)
    guide = create(:guide)

    manager = described_class.new(guide: guide, user: user)
    manager.request_review!

    expect(guide.latest_edition.created_by).to eq(user)
  end
end

RSpec.describe GuideManager, '#approve_for_publication!' do
  it "creates a new edition with a state of 'ready'" do
    user = create(:user)
    guide = create(:guide, :with_review_requested_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.approve_for_publication!

    expect(guide.latest_edition.state).to eq('ready')
  end

  it "creates a new edition created by the supplied user" do
    user = create(:user)
    guide = create(:guide, :with_review_requested_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.approve_for_publication!

    expect(guide.latest_edition.created_by).to eq(user)
  end

  it "delivers a notification" do
    user = create(:user)
    guide = create(:guide, :with_review_requested_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.approve_for_publication!

    expect(
      ActionMailer::Base.deliveries.last.subject
    ).to include("ready for publishing")
  end
end

RSpec.describe GuideManager, '#publish' do
  before do
    stub_any_publishing_api_publish
    stub_any_rummager_post
  end

  it "creates a new edition with a state of 'published'" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    expect(guide.latest_edition.state).to eq('published')
  end

  it "creates a new edition created by the supplied user" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    expect(guide.latest_edition.created_by).to eq(user)
  end

  it 'publishes the guide against the publishing api' do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    assert_publishing_api_publish(guide.content_id)
  end

  it 'indexes the document with rummager' do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    assert_rummager_posted_item({ link: guide.slug }.as_json)
  end

  it "delivers a notification" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    expect(
      ActionMailer::Base.deliveries.last.subject
    ).to include("has been published")
  end

  it "is successful" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    result = manager.publish

    expect(result).to be_success
  end

  it "saves and publishes the service standard with other published points if publishing a point" do
    user = create(:user)

    create(:point, :with_published_edition, title: 'Scrum')
    point = create(:point, :with_ready_edition, title: 'Agile')

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
      guide = create(:guide, :with_ready_edition)

      manager = described_class.new(guide: guide, user: user)
      manager.publish

      expect(guide.editions.published).to be_empty
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it "is not successful and has an error" do
      stub_publishing_api_to_fail

      user = create(:user)
      guide = create(:guide, :with_ready_edition)

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
end

RSpec.describe GuideManager, '#unpublish_with_redirect' do
  before do
    stub_any_publishing_api_call
    stub_any_rummager_delete_content
  end

  it "creates a new edition with a state of 'unpublished'" do
    user = create(:user)
    guide = create(:guide, :with_published_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.unpublish_with_redirect('/service-manual/somewhere-else')

    expect(guide.latest_edition.state).to eq('unpublished')
  end

  it 'creates a new edition created by the supplied user' do
    user = create(:user)
    guide = create(:guide, :with_published_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.unpublish_with_redirect('/service-manual/somewhere-else')

    expect(guide.latest_edition.created_by).to eq(user)
  end

  it 'unpublishes the guide and creates a redirect with the publishing api' do
    user = create(:user)
    guide = create(:guide, :with_published_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.unpublish_with_redirect('/service-manual/suitable-redirect')

    assert_publishing_api_unpublish(guide.content_id,
      type: 'redirect',
      alternative_path: '/service-manual/suitable-redirect'
    )
  end

  it 'deletes the document from rummager' do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.unpublish_with_redirect('/service-manual/suitable-redirect')

    assert_rummager_deleted_content(guide.slug)
  end

  it "is successful" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    result = manager.unpublish_with_redirect('/service-manual/suitable-redirect')

    expect(result).to be_success
  end

  context "when communication with the publishing api fails" do
    before do
      publishing_api_isnt_available
    end

    it 'does not create a new edition' do
      user = create(:user)
      guide = create(:guide, :with_published_edition)

      manager = described_class.new(guide: guide, user: user)
      manager.unpublish_with_redirect('/service-manual/somewhere-else')

      expect(guide.latest_edition.state).to eq('published')
    end

    it 'is not successful and returns an error' do
      user = create(:user)
      guide = create(:guide, :with_published_edition)

      manager = described_class.new(guide: guide, user: user)
      result = manager.unpublish_with_redirect('/service-manual/somewhere-else')

      expect(result).to_not be_success
      expect(result.errors).to include('Could not communicate with upstream API')
    end
  end

  context 'when rummager returns a 404 trying to delete the content' do
    before do
      stub_any_publishing_api_call
      stub_any_rummager_delete_content.to_return(status: [404, "Not Found"])
      # stub_const("Airbrake", double(:airbrake))
    end

    it 'sends a notification to Airbrake' do
      user = create(:user)
      guide = create(:guide, :with_published_edition)

      expect(Airbrake).to receive(:notify)

      manager = described_class.new(guide: guide, user: user)
      result = manager.unpublish_with_redirect('/service-manual/suitable-redirect')
    end

    it 'is successful' do
      user = create(:user)
      guide = create(:guide, :with_published_edition)

      manager = described_class.new(guide: guide, user: user)
      result = manager.unpublish_with_redirect('/service-manual/suitable-redirect')

      expect(result).to be_success
    end
  end
end

RSpec.describe GuideManager, '#discard_draft' do
  context "without published editions" do
    it "destroys the guide and all editions" do
      user = create(:user)
      guide = create(:guide)

      stub_publishing_api_discard_draft(guide.content_id)

      manager = described_class.new(guide: guide, user: user)
      manager.discard_draft

      guide_id = guide.id
      expect(Guide.find_by_id(guide_id)).to eq(nil)
      expect(Edition.where(guide_id: guide_id).count).to eq(0)
    end

    it 'discards drafts against the publishing api' do
      user = create(:user)
      guide = create(:guide)

      stub_publishing_api_discard_draft(guide.content_id)

      manager = described_class.new(guide: guide, user: user)
      manager.discard_draft

      assert_publishing_api_discard_draft(guide.content_id)
    end

    it "is successful" do
      user = create(:user)
      guide = create(:guide)

      stub_publishing_api_discard_draft(guide.content_id)

      manager = described_class.new(guide: guide, user: user)
      result = manager.discard_draft

      expect(result).to be_success
    end
  end

  context "with published editions" do
    it "destroys just the editions since the last published edition" do
      user = create(:user)
      guide = create_guide

      stub_publishing_api_discard_draft(guide.content_id)

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
      publishing_api_isnt_available

      user = create(:user)
      guide = create(:guide, :with_topic_section)

      manager = described_class.new(guide: guide, user: user)
      manager.discard_draft

      expect(Guide.find_by_id(guide.id)).to be_present
    end
  end
end
