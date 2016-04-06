class EditionThread
  def initialize(most_recent_edition)
    @most_recent_edition = most_recent_edition
    @events = []
  end

  def events
    @events << NewDraftEvent.new(all_editions_in_thread.first, all_editions_in_thread.first.updated_at)
    @events << AssignedToEvent.new(all_editions_in_thread.first, all_editions_in_thread.first.updated_at)

    current_state = all_editions_in_thread.first.state

    all_editions_in_thread.each do |edition|
      if edition.state != current_state
        @events << StateChangeEvent.new(edition, edition.updated_at)

        current_state = edition.state
      end

      edition.comments.includes(:user).oldest_first.each do |comment|
        @events << CommentEvent.new(comment, comment.created_at)
      end
    end

    @events
  end

private

  def all_editions_in_thread
    @_all_editions_in_thread =
      Edition.where(guide_id: @most_recent_edition.guide_id, version: @most_recent_edition.version)
             .order('created_at')
  end

  NewDraftEvent = Struct.new(:edition, :at)
  AssignedToEvent = Struct.new(:edition, :at)
  CommentEvent = Struct.new(:comment, :at)
  StateChangeEvent = Struct.new(:edition, :at)
end
