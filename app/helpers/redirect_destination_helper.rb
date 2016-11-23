module RedirectDestinationHelper
  def redirect_destination_select_options
    {
      "Other" => ["/service-manual", "/service-manual/service-standard"],
      "Topics" => topic_select_options,
      "Guides" => guide_select_options,
    }
  end

private

  def guide_select_options
    Guide.live.order(:slug).pluck(:slug)
  end

  def topic_select_options
    Topic.includes(:topic_sections).order(:path)
      .flat_map { |topic| paths_for_topic_and_its_sections(topic) }
  end

  def paths_for_topic_and_its_sections(topic)
    topic_sections = topic.topic_sections.order(:title).where("title <> ''").map do |section|
      ["#{topic.path} → #{section.title}", "#{topic.path}##{section.title.parameterize}"]
    end

    [topic.path, *topic_sections]
  end
end
