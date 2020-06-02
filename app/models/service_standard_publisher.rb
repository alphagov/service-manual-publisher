class ServiceStandardPublisher
  def initialize
    @service_standard = ServiceStandardPresenter.new
  end

  def save_draft
    PUBLISHING_API.put_content(
      service_standard.content_id,
      service_standard.content_payload,
    )

    PUBLISHING_API.patch_links(
      service_standard.content_id,
      service_standard.links_payload,
    )
  end

  def publish
    PUBLISHING_API.publish(service_standard.content_id)
  end

private

  attr_reader :service_standard
end
