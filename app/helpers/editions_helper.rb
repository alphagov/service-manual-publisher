module EditionsHelper
  def event_action_for_changed_state(state)
    case state
    when "ready"
      "Approved"
    else
      state.humanize
    end
  end

  def edition_created_by_name(edition)
    if edition.created_by
      edition.created_by.name
    else
      "Unknown"
    end
  end
end
