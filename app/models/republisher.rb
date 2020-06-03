class Republisher
  def call(presenter)
    GdsApi.publishing_api.put_content(
      presenter.content_id,
      presenter.content_payload,
    )

    GdsApi.publishing_api.patch_links(
      presenter.content_id,
      presenter.links_payload.merge(bulk_publishing: true),
    )

    GdsApi.publishing_api.publish(
      presenter.content_id,
      "republish",
    )
  end
end
