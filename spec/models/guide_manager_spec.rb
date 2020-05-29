require "rails_helper"

RSpec.describe GuideManager, "#request_review!" do
  it "creates a new edition with a state of 'review_requested'" do
    user = create(:user)
    guide = create(:guide)

    manager = described_class.new(guide: guide, user: user)
    manager.request_review!

    expect(guide.latest_edition.state).to eq("review_requested")
  end

  it "creates a new edition created by the supplied user" do
    user = create(:user)
    guide = create(:guide)

    manager = described_class.new(guide: guide, user: user)
    manager.request_review!

    expect(guide.latest_edition.created_by).to eq(user)
  end

  it "is successful" do
    user = create(:user)
    guide = create(:guide, :with_draft_edition)

    manager = described_class.new(guide: guide, user: user)
    result = manager.request_review!

    expect(result).to be_success
  end
end

RSpec.describe GuideManager, "#approve_for_publication!" do
  it "creates a new edition with a state of 'ready'" do
    user = create(:user)
    guide = create(:guide, :with_review_requested_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.approve_for_publication!

    expect(guide.latest_edition.state).to eq("ready")
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
      ActionMailer::Base.deliveries.last.subject,
    ).to include("ready for publishing")
  end

  it "is successful" do
    user = create(:user)
    guide = create(:guide, :with_review_requested_edition)

    manager = described_class.new(guide: guide, user: user)
    result = manager.approve_for_publication!

    expect(result).to be_success
  end
end

RSpec.describe GuideManager, "#publish" do
  before do
    stub_any_publishing_api_publish
  end

  it "creates a new edition with a state of 'published'" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    expect(guide.latest_edition.state).to eq("published")
  end

  it "creates a new edition created by the supplied user" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    expect(guide.latest_edition.created_by).to eq(user)
  end

  it "publishes the guide against the publishing api" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    assert_publishing_api_publish(guide.content_id)
  end

  it "delivers a notification" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.publish

    expect(
      ActionMailer::Base.deliveries.last.subject,
    ).to include("has been published")
  end

  it "is successful" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    result = manager.publish

    expect(result).to be_success
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
      expect(result.errors).to include("trouble")
    end

    def stub_publishing_api_to_fail
      gds_api_exception = GdsApi::HTTPErrorResponse.new(
        422,
        "https://some-service.gov.uk",
        "error" => { "message" => "trouble" },
      )
      expect(PUBLISHING_API).to receive(:publish).and_raise(gds_api_exception)
    end
  end
end

RSpec.describe GuideManager, "#unpublish_with_redirect" do
  before do
    stub_any_publishing_api_call
  end

  it "creates a new edition with a state of 'unpublished'" do
    user = create(:user)
    guide = create(:guide, :with_published_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.unpublish_with_redirect("/service-manual/somewhere-else")

    expect(guide.latest_edition.state).to eq("unpublished")
  end

  it "creates a new edition created by the supplied user" do
    user = create(:user)
    guide = create(:guide, :with_published_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.unpublish_with_redirect("/service-manual/somewhere-else")

    expect(guide.latest_edition.created_by).to eq(user)
  end

  it "unpublishes the guide and creates a redirect with the publishing api" do
    user = create(:user)
    guide = create(:guide, :with_published_edition)

    manager = described_class.new(guide: guide, user: user)
    manager.unpublish_with_redirect("/service-manual/suitable-redirect")

    assert_publishing_api_unpublish(
      guide.content_id,
      type: "redirect",
      alternative_path: "/service-manual/suitable-redirect",
    )
  end

  it "is successful" do
    user = create(:user)
    guide = create(:guide, :with_ready_edition)

    manager = described_class.new(guide: guide, user: user)
    result = manager.unpublish_with_redirect("/service-manual/suitable-redirect")

    expect(result).to be_success
  end

  context "when communication with the publishing api fails" do
    before do
      stub_publishing_api_isnt_available
    end

    it "does not create a new edition" do
      user = create(:user)
      guide = create(:guide, :with_published_edition)

      manager = described_class.new(guide: guide, user: user)
      manager.unpublish_with_redirect("/service-manual/somewhere-else")

      expect(guide.latest_edition.state).to eq("published")
    end

    it "sends a notification to Sentry" do
      user = create(:user)
      guide = create(:guide, :with_published_edition)

      expect(GovukError).to receive(:notify)

      manager = described_class.new(guide: guide, user: user)
      manager.unpublish_with_redirect("/service-manual/suitable-redirect")
    end

    it "is not successful and returns an error" do
      user = create(:user)
      guide = create(:guide, :with_published_edition)

      manager = described_class.new(guide: guide, user: user)
      result = manager.unpublish_with_redirect("/service-manual/somewhere-else")

      expect(result).to_not be_success
      expect(result.errors).to include("Could not communicate with upstream API")
    end
  end
end

RSpec.describe GuideManager, "#discard_draft" do
  context "without published editions" do
    it "destroys the guide and all editions" do
      user = create(:user)
      guide = create(:guide)

      stub_publishing_api_discard_draft(guide.content_id)

      manager = described_class.new(guide: guide, user: user)
      manager.discard_draft

      guide_id = guide.id
      expect(Guide.find_by(id: guide_id)).to eq(nil)
      expect(Edition.where(guide_id: guide_id).count).to eq(0)
    end

    it "discards drafts against the publishing api" do
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

      expect(guide.editions.where(title: "Agile").count).to eq(4)
      expect(guide.latest_edition.state).to eq("published")
      expect(guide.editions.where(title: "Agile amended")).to be_empty
    end

    def create_guide
      editions = [
        build(:edition, title: "Agile"),
        build(:edition, title: "Agile", state: "review_requested"),
        build(:edition, title: "Agile", state: "ready"),
        build(:edition, title: "Agile", state: "published"),
        build(:edition, title: "Agile amended"),
        build(:edition, title: "Agile amended", state: "review_requested"),
      ]
      create(:guide, editions: editions)
    end
  end

  context "when communication with the publishing api fails" do
    it "doesn't destroy anything if communication with the publishing api fails" do
      stub_publishing_api_isnt_available

      user = create(:user)
      guide = create(:guide)

      manager = described_class.new(guide: guide, user: user)
      manager.discard_draft

      expect(Guide.find_by(id: guide.id)).to be_present
    end
  end
end
