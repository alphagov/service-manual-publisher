class PointForm < BaseGuideForm
  def requires_topic?
    false
  end

  def slug_prefix
    "/service-manual/service-standard"
  end

private

  def save_draft_to_publishing_api
    super

    service_standard_for_publication = ServiceStandardPresenter.new(Point.all)
    PUBLISHING_API.put_content(
      service_standard_for_publication.content_id,
      service_standard_for_publication.content_payload
    )
  end
end
