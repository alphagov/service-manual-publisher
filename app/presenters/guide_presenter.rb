class GuidePresenter
  def initialize(guide, edition)
    @guide = guide
    @edition = edition
  end

  delegate :content_id, to: :guide

  def content_payload
    {
      publishing_app: "service-manual-publisher",
      rendering_app: "frontend",
      schema_name: "service_manual_guide",
      document_type: "service_manual_guide",
      locale: "en",
      update_type: edition.update_type,
      base_path: guide.slug,
      title: edition.title,
      description: edition.description,
      routes: [
        { type: "exact", path: guide.slug },
      ],
      details:,
    }
  end

  def links_payload
    links = {
      organisations: [ServiceManualPublisher::GDS_ORGANISATION_CONTENT_ID],
      primary_publishing_organisation: [ServiceManualPublisher::GDS_ORGANISATION_CONTENT_ID],
    }

    if guide.topic
      links[:service_manual_topics] = [guide.topic.content_id]
    end

    if edition.content_owner
      links[:content_owners] = [edition.content_owner.content_id]
    end

    if guide.is_a?(Point)
      links[:parent] = [ServiceStandardPresenter::SERVICE_STANDARD_CONTENT_ID]
    end

    { links: }
  end

private

  attr_reader :guide, :edition

  def details
    details_hash = {
      body: govspeak_body.to_html,
      header_links: level_two_headers,
      change_history: ChangeHistoryPresenter.new(guide, edition).change_history,
      change_note: latest_change_note_for_email_notification,
    }

    if guide.is_a?(Point)
      details_hash[:show_description] = true
    end

    details_hash
  end

  def govspeak_body
    Govspeak::Document.new(edition.body)
  end

  def latest_change_note_for_email_notification
    edition.change_note
  end

  def level_two_headers
    govspeak_body
      .structured_headers
      .select { |s| s.level == 2 }
      .map { |h2| { title: h2.text, href: "##{h2.id}" } }
  end
end
