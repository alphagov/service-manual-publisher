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
      ids = group["guides"]
      guides = Guide.find(ids)
      guides = ids.map{|id| guides.detect{|guide| guide.id == Integer(id)}}

      {
        name: group['title'],
        description: group['description'],
        contents: guides.map {|g| g.slug},
        content_ids: guides.map {|g| g.content_id},
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
