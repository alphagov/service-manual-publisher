class GuideChangeHistoryPresenter
  def initialize(guide, edition)
    @guide = guide
    @edition = edition
  end

  def change_history
    editions.map { |edition| history_entry(edition) }
  end

private

  def editions
    guide.editions
      .published.major.where('id <> ?', edition.id)
      .order(created_at: :desc)
  end

  def history_entry(edition)
    {
      public_timestamp: edition.created_at.iso8601,
      note: edition.change_summary,
      reason_for_change: edition.change_note
    }
  end

  attr_reader :guide, :edition
end
