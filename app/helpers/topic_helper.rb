module TopicHelper
  def view_topic_url(topic)
    [Plek.new.website_root, topic.path].join("")
  end

  def all_guides_container_for_select
    # TODO: N+1 on loading the most recent edition
    @all_guides_container_for_select ||=
      Guide.all.sort_by(&:title).map do |guide|
        [guide.title, guide.id]
      end
  end
end
