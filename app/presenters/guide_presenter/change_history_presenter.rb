class GuidePresenter::ChangeHistoryPresenter
  def initialize(guide, current_edition)
    @guide = guide
    @current_edition = current_edition
  end

  def change_history
    major_editions.map do |edition|
      {
        public_timestamp: edition.created_at.iso8601,
        note: edition.change_note
      }
    end
  end

private

  def major_editions
    if current_edition.major?
      previously_published_major_editions.unshift(current_edition).uniq
    else
      previously_published_major_editions
    end
  end

  def previously_published_major_editions
    guide.editions
      .published.major
      .order(created_at: :desc)
  end

  attr_reader :guide, :current_edition
end
