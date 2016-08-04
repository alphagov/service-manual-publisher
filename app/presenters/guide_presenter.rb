class GuidePresenter
  def initialize(guide, edition)
    @guide = guide
    @edition = edition
  end

  def content_id
    guide.content_id
  end

  def content_payload
    {
      publishing_app: "service-manual-publisher",
      rendering_app: "service-manual-frontend",
      format: "service_manual_guide",
      locale: "en",
      update_type: edition.update_type,
      base_path: guide.slug,
      title: edition.title,
      description: edition.description,
      phase: edition.phase,
      routes: [
        { type: "exact", path: guide.slug }
      ],
      details: details
    }
  end

  def links_payload
    links = {
      organisations: [ServiceManualPublisher::GDS_ORGANISATION_CONTENT_ID],
    }

    if edition.content_owner
      links[:content_owners] = [edition.content_owner.content_id]
    end

    if guide.is_a?(Point)
      links[:parent] = [ServiceStandardPresenter::SERVICE_STANDARD_CONTENT_ID]
    end

    { links: links }
  end

private

  attr_reader :guide, :edition

  def details
    details_hash = {
      body: govspeak_body.to_html,
      header_links: level_two_headers,
      change_history: GuidePresenter::ChangeHistoryPresenter.new(guide, edition).change_history
    }

    if guide.is_a?(Point)
      details_hash[:show_description] = true
    end

    details_hash
  end

  def govspeak_body
    Govspeak::Document.new(edition.body)
  end

  def level_two_headers
    govspeak_body
      .structured_headers
      .select { |s| s.level == 2 }
      .map { |h2| { title: h2.text, href: "##{h2.id}" } }
  end
end
