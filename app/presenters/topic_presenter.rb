class TopicPresenter
  def initialize(topic)
    @topic = topic
  end

  def content_id
    topic.content_id
  end

  def content_payload
    {
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

  def links_payload
    {
      links: {
        linked_items: eagerloaded_guides.map(&:content_id),
        content_owners: content_owner_content_ids,
      }
    }
  end

private

  attr_reader :topic

  def groups
    topic.topic_sections.map do |topic_section|
      {
        name: topic_section.title,
        description: topic_section.description,
        contents: topic_section.guides.map(&:slug),
        content_ids: topic_section.guides.map(&:content_id),
      }
    end
  end

  def content_owner_content_ids
    content_ids = eagerloaded_guides.map do |guide|
      edition = guide.latest_edition

      if edition.content_owner
        edition.content_owner.content_id
      end
    end
    content_ids.compact.uniq
  end

  def eagerloaded_guides
    topic.topic_sections.map do |topic_section|
      topic_section.guides.to_a
    end.flatten.uniq
  end
end
