module TopicHelper
  def view_topic_url(topic)
    [Plek.new.website_root, topic.path].join('')
  end

  def all_guides_container_for_select
    @_all_guides_container_for_select ||=
      Guide.includes(:latest_edition).sort_by(&:title).map do |guide|
        [guide.title, guide.id]
      end
  end
end
