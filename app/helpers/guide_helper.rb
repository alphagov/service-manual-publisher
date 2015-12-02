module GuideHelper
  STATE_CSS_CLASSES = {
    "new"              => "default",
    "draft"            => "danger",
    "review_requested" => "warning",
    "approved"         => "success",
    "published"        => "info",
  }

  def state_label(state)
    title     = state.titleize
    css_class = STATE_CSS_CLASSES[state]
    content_tag :span, title, title: 'State', class: "label label-#{css_class}"
  end

  def latest_editor_name(guide)
    guide.latest_edition.user.try(:name).to_s
  end
end
