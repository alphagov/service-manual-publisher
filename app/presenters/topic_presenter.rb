class TopicPresenter
  def initialize(topic)
    @topic = topic
  end

  def exportable_attributes
    {
      content_id: topic.content_id,
      publishing_app: "service-manual-publisher",
      rendering_app: "government-frontend",
      format: "service_manual_topic",
      locale: "en",
      update_type: "minor",
      base_path: topic.path,
      public_updated_at: topic.updated_at.iso8601,
      title: topic.title,
      description: topic.description,
      phase: "beta",
      routes: [
        { type: "exact", path: topic.path }
      ],
      details: {
        groups: groups
      }
    }
  end

  def links
    {
      links: {
        linked_items: eagerloaded_guides.map { |guide| guide.content_id }
      }
    }
  end

private

  attr_reader :topic

  def groups
    topic_groups.map do |group|
      guides = Guide.where(id: group["guides"]).pluck(:slug, :content_id)
      {
        name: group['title'],
        description: group['description'],
        contents: guides.map {|g| g.first},
        content_ids: guides.map {|g| g.last},
      }
    end
  end

  def eagerloaded_guides
    @eagerloaded_guides ||= begin
      ids = topic_groups.flat_map { |group| group['guides'] }.uniq
      Guide.where(id: ids)
    end
  end

  def topic_groups
    @topic_groups ||= topic.tree.select { |h| h.is_a?(Hash) }
  end
end
