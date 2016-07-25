class GuideChangeHistoryPresenter
  def initialize(guide)
    @guide = guide
  end

  def change_history
    editions.map { |edition| history_entry(edition) }
  end

private

  def editions
    guide.editions.published.major.order(:created_at)
  end

  def history_entry(edition)
    {
      public_timestamp: edition.created_at.iso8601,
      note: edition.change_summary,
      reason_for_change: edition.change_note
    }
  end

  attr_reader :guide
end
