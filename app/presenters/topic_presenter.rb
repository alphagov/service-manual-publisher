class TopicPresenter
  def initialize(topic)
    @topic = topic
  end

  def exportable_attributes
    {
      content_id: topic.content_id,
      publishing_app: "service-manual-publisher",
      rendering_app: "government-frontend",
      format: "topic",
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
        linked_items: eagerloaded_editions.map { |edition| edition.guide.content_id }
      }
    }
  end

private

  attr_reader :topic

  def groups
    topic_groups.map do |group|
      {
        name: group['title'],
        description: group['description'],
        contents: attributes_of(group['editions'], :slug),
        content_ids: attributes_of(group['editions'], :content_id)
      }
    end
  end

  def eagerloaded_editions
    @eagerloaded_editions ||= begin
      ids = topic_groups.flat_map { |group| group['editions'] }.uniq
      Edition.where(id: ids).includes(:guide)
    end
  end

  def topic_groups
    @topic_groups ||= topic.tree.select { |h| h.is_a?(Hash) }
  end

  def attributes_of(edition_ids, guide_attribute)
    edition_ids.map do |edition_id|
      guide = eagerloaded_editions.find { |edition| edition.id.to_s == edition_id.to_s }.guide
      guide.public_send(guide_attribute)
    end
  end
end
