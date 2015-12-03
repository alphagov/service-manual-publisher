module GuideHelper
  STATE_CSS_CLASSES = {
    "new"              => "default",
    "draft"            => "danger",
    "review_requested" => "warning",
    "approved"         => "success",
    "published"        => "info",
  }

  def state_label(guide)
    state     = guide.latest_edition.try(:state) || "new"
    title     = state.titleize
    css_class = STATE_CSS_CLASSES[state]
    content_tag :span, title, title: 'State', class: "label label-#{css_class}"
  end

  def guide_action_button(guide)
    state = guide.latest_edition.state
    if state == "draft" || state == "published"
      title = "Edit"
      path =  edit_guide_path(guide)
    elsif state == "review_requested"
      title = "Review guide"
      path = edition_path(guide.latest_edition)
    elsif state == "approved"
      title = "Publish"
      path = edition_path(guide.latest_edition)
    end
    link_to title, path, class: "btn btn-block btn-default btn-xs"
  end

  def latest_editor_name(guide)
    guide.latest_edition.user.try(:name).to_s
  end
end
