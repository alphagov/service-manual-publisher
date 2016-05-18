module GuideHelper
  STATE_CSS_CLASSES = {
    "draft"            => "danger",
    "review_requested" => "warning",
    "ready"            => "success",
    "published"        => "info",
    "unpublished"      => "default",
  }

  def state_label(guide)
    state     = guide.latest_edition.try(:state)
    title     = state.titleize
    css_class = STATE_CSS_CLASSES[state]
    content_tag :span, title, title: 'State', class: "label label-#{css_class}"
  end

  def latest_author_name(guide)
    guide.latest_edition.author.try(:name).to_s
  end

  def guide_community_options_for_select
    # TODO: N+1 on loading the most recent edition
    GuideCommunity.all.
          sort_by{ |guide| guide.title }.
          map{ |g| [g.title, g.id] }
  end

  def topic_section_options_for_select
    Topic.all.map do |topic|
      [
        topic.title,
        topic.topic_sections.map { |ts| [ "#{topic.title} -> #{ts.title}", ts.id ] },
        { "data-path" => topic.path }
      ]
    end
  end

  def guide_form_for(guide, *args, &block)
    options = args.extract_options!
    url = url_for(guide.becomes(Guide))

    form_for(guide, *args << options.merge(as: :guide, url: url), &block)
  end

  def guide_community_title(guide_community)
    guide_community.title.gsub(/ [cC]ommunity$/, "")
  end
end
