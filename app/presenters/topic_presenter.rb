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
      rendering_app: "service-manual-frontend",
      schema_name: "service_manual_topic",
      document_type: "service_manual_topic",
      locale: "en",
      update_type: "minor",
      base_path: topic.path,
      title: topic.title,
      description: topic.description,
      phase: "beta",
      routes: [
        { type: "exact", path: topic.path }
      ],
      details: {
        visually_collapsed: topic.visually_collapsed,
        groups: groups
      }
    }
  end

  def links_payload
    {
      links: {
        linked_items: topic.guides.map(&:content_id),
        content_owners: content_owner_content_ids,
        organisations: [ServiceManualPublisher::GDS_ORGANISATION_CONTENT_ID],
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
        content_ids: topic_section.guides.map(&:content_id),
      }
    end
  end

  def content_owner_content_ids
    content_ids = topic.guides.map do |guide|
      edition = guide.latest_edition

      edition.content_owner.content_id if edition.content_owner
    end
    content_ids.compact.uniq
  end
end
