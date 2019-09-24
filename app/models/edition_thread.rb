class EditionThread
  def initialize(most_recent_edition)
    @most_recent_edition = most_recent_edition
    @events = []
  end

  def events
    @events << NewDraftEvent.new(all_editions_in_thread.first)
    @events << AuthorAutoAssignedEvent.new(all_editions_in_thread.first)

    current_state = all_editions_in_thread.first.state
    current_author = all_editions_in_thread.first.author.name

    all_editions_in_thread.each do |edition|
      if edition.state != current_state
        @events << StateChangeEvent.new(edition)

        current_state = edition.state
      end

      if edition.author.name != current_author
        @events << AuthorChangedEvent.new(edition)

        current_author = edition.author.name
      end

      edition.comments.includes(:user).oldest_first.each do |comment|
        @events << CommentEvent.new(comment)
      end
    end

    @events
  end

private

  def all_editions_in_thread
    @_all_editions_in_thread =
      Edition.where(guide_id: @most_recent_edition.guide_id, version: @most_recent_edition.version)
        .order("created_at")
  end

  NewDraftEvent = Struct.new(:edition)
  AuthorAutoAssignedEvent = Struct.new(:edition)
  AuthorChangedEvent = Struct.new(:edition)
  CommentEvent = Struct.new(:comment)
  StateChangeEvent = Struct.new(:edition)
end
