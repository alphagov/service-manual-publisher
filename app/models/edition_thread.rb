class EditionThread
  def initialize(most_recent_edition)
    @most_recent_edition = most_recent_edition
  end

  def events
    @events = []
    @events << NewDraftEvent.new(all_editions_in_thread.first)
    @events << AssignedToEvent.new(all_editions_in_thread.first)
    all_editions_in_thread.each do |edition|
      edition.comments.each do |comment|
        @events << CommentEvent.new(comment)
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

  NewDraftEvent = Struct.new(:edition)
  AssignedToEvent = Struct.new(:edition)
  CommentEvent = Struct.new(:comment)
end
