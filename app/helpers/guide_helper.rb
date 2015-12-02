module GuideHelper
  STATE_CSS_CLASSES = {
    "new"              => "default",
    "draft"            => "danger",
    "review_requested" => "warning",
    "approved"         => "success",
    "published"        => "info",
  }

  def state_progress_bar(guide)
    state = guide.latest_edition.state
    return "" if state.nil?

    states = %w(draft review_requested approved published)

    html = '<div class="progress">'
    states.each do |s|
      html << <<-HTML
                  <div class="progress-bar progress-bar-#{STATE_CSS_CLASSES.fetch(s)}" style="width: 25%">
                    <span>#{s.humanize}</span>
                  </div>
      HTML
      break if s == state
    end
    html << "</div>"
    html.html_safe
  end

  def state_label(guide)
    state     = guide.latest_edition.try(:state) || "new"
    title     = state.titleize
    css_class = STATE_CSS_CLASSES[state]
    content_tag :span, title, title: 'State', class: "label label-#{css_class}"
  end

  def latest_editor_name(guide)
    guide.latest_edition.user.try(:name).to_s
  end
end
