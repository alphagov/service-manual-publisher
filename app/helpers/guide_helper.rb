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

  def guide_community_options_for_select
    GuideCommunity.includes(:latest_edition).
          sort_by{ |guide| guide.title }.
          map{ |g| [g.title, g.id] }
  end

  def guide_form_for(guide, *args, &block)
    options = args.extract_options!
    url = url_for(guide.becomes(Guide))

    form_for(guide, *args << options.merge(as: :guide, url: url), &block)
  end
end
