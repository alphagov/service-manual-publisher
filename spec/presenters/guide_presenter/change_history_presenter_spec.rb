require 'rails_helper'

RSpec.describe GuidePresenter::ChangeHistoryPresenter do
  it 'includes all major editions in reverse chronological order' do
    editions = [
      *published_edition(
        change_note: "Guidance first published",
        reason_for_change: nil,
        update_type: "major",
        created_at: "2016-06-25T14:16:21Z"
      ),
      *published_edition(
        change_note: "Big content change",
        reason_for_change: "Needed updating",
        update_type: "major",
        created_at: "2016-06-28T14:16:21Z"
      )
    ]

    guide = create(:guide, editions: editions)
    presenter = described_class.new(guide, guide.latest_edition)

    expect(presenter.change_history).to eq [
      {
        public_timestamp: "2016-06-28T14:16:21Z",
        note: "Big content change",
        reason_for_change: "Needed updating"
      },
      {
        public_timestamp: "2016-06-25T14:16:21Z",
        note: "Guidance first published",
        reason_for_change: ""
      }
    ]
  end

  it 'includes the change note of the current draft if it is major' do
    editions = [
      *published_edition(
        change_note: "Guidance first published",
        reason_for_change: nil,
        update_type: "major",
        created_at: "2016-06-25T14:16:21Z"
      ),
      *draft_edition(
        change_note: "Big content change",
        reason_for_change: "Needed updating",
        update_type: "major",
        created_at: "2016-06-28T14:16:21Z"
      )
    ]

    guide = create(:guide, editions: editions)
    presenter = described_class.new(guide, guide.latest_edition)

    expect(presenter.change_history).to eq [
      {
        public_timestamp: "2016-06-28T14:16:21Z",
        note: "Big content change",
        reason_for_change: "Needed updating"
      },
      {
        public_timestamp: "2016-06-25T14:16:21Z",
        note: "Guidance first published",
        reason_for_change: ""
      }
    ]
  end

  it 'does not include the current draft if it is a minor' do
    editions = [
      *published_edition(
        change_note: "Guidance first published",
        reason_for_change: nil,
        update_type: "major",
        created_at: "2016-06-25T14:16:21Z"
      ),
      *draft_edition(
        change_note: "",
        reason_for_change: "",
        update_type: "minor",
        created_at: "2016-06-28T14:16:21Z",
        version: 2
      )
    ]

    guide = create(:guide, editions: editions)
    presenter = described_class.new(guide, guide.latest_edition)

    expect(presenter.change_history).to eq [
      {
        public_timestamp: "2016-06-25T14:16:21Z",
        note: "Guidance first published",
        reason_for_change: ""
      }
    ]
  end

  it 'assigns the reason_for_change an empty string if the reason_for_change is nil' \
    ' because the definition in the content schema requires it' do
    editions = published_edition(
      change_note: "Guidance first published",
      reason_for_change: nil,
      update_type: "major",
      created_at: "2016-06-25T14:16:21Z"
    )

    guide = create(:guide, editions: editions)
    presenter = described_class.new(guide, guide.latest_edition)

    expect(presenter.change_history).to eq [
      {
        public_timestamp: "2016-06-25T14:16:21Z",
        note: "Guidance first published",
        reason_for_change: ""
      }
    ]
  end

private

  def published_edition(attributes)
    [
      build(:edition, :draft, **attributes),
      build(:edition, :review_requested, **attributes),
      build(:edition, :ready, **attributes),
      build(:edition, :published, **attributes)
    ]
  end

  def draft_edition(attributes)
    [
      build(:edition, :draft, **attributes)
    ]
  end
end
