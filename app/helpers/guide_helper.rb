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
    title = {
      "review_requested" => "Review guide",
      "approved" => "Publish",
    }[guide.latest_edition.state] || "Edit"
    link_to title, edit_guide_path(guide), class: "btn btn-block btn-default btn-xs"
  end

  def latest_editor_name(guide)
    guide.latest_edition.user.try(:name).to_s
  end
end
