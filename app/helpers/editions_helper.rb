module EditionsHelper
  def event_action_for_changed_state(state)
    case state
    when "ready"
      "Approved"
    else
      state.humanize
    end
  end
end
