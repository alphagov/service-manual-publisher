require "rails_helper"

RSpec.describe GuidePresenter::ChangeHistoryPresenter do
  it "includes all major editions in reverse chronological order" do
    editions = [
      *published_edition(
        change_note: "Guidance first published",
        update_type: "major",
        created_at: Time.zone.parse("2016-06-25 14:16:21").as_json,
      ),
      *published_edition(
        change_note: "Big content change",
        update_type: "major",
        created_at: Time.zone.parse("2016-06-28 14:16:21").as_json,
      ),
    ]

    guide = create(:guide, editions:)
    presenter = described_class.new(guide, guide.latest_edition)

    expect(presenter.change_history).to eq [
      {
        public_timestamp: Time.zone.parse("2016-06-28 14:16:21").as_json,
        note: "Big content change",
      },
      {
        public_timestamp: Time.zone.parse("2016-06-25 14:16:21").as_json,
        note: "Guidance first published",
      },
    ]
  end

  it "includes the change note of the current draft if it is major" do
    editions = [
      *published_edition(
        change_note: "Guidance first published",
        update_type: "major",
        created_at: Time.zone.parse("2016-06-25 14:16:21").as_json,
      ),
      *draft_edition(
        change_note: "Big content change",
        update_type: "major",
        created_at: Time.zone.parse("2016-06-28 14:16:21").as_json,
      ),
    ]

    guide = create(:guide, editions:)
    presenter = described_class.new(guide, guide.latest_edition)

    expect(presenter.change_history).to eq [
      {
        public_timestamp: Time.zone.parse("2016-06-28 14:16:21").as_json,
        note: "Big content change",
      },
      {
        public_timestamp: Time.zone.parse("2016-06-25 14:16:21").as_json,
        note: "Guidance first published",
      },
    ]
  end

  it "does not include the current draft if it is a minor" do
    editions = [
      *published_edition(
        change_note: "Guidance first published",
        update_type: "major",
        created_at: Time.zone.parse("2016-06-25 14:16:21").as_json,
      ),
      *draft_edition(
        change_note: "",
        update_type: "minor",
        created_at: Time.zone.parse("2016-06-28 14:16:21").as_json,
        version: 2,
      ),
    ]

    guide = create(:guide, editions:)
    presenter = described_class.new(guide, guide.latest_edition)

    expect(presenter.change_history).to eq [
      {
        public_timestamp: Time.zone.parse("2016-06-25 14:16:21").as_json,
        note: "Guidance first published",
      },
    ]
  end

private

  def published_edition(attributes)
    [
      build(:edition, :draft, **attributes),
      build(:edition, :review_requested, **attributes),
      build(:edition, :ready, **attributes),
      build(:edition, :published, **attributes),
    ]
  end

  def draft_edition(attributes)
    [
      build(:edition, :draft, **attributes),
    ]
  end
end
