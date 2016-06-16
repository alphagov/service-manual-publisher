class GuideRepublisher
  def initialize(guide, publishing_api: PUBLISHING_API)
    @guide = guide
    @publishing_api = publishing_api
  end

  def republish
    live_edition = guide.live_edition

    if live_edition
      guide_for_publication = GuidePresenter.new(guide, live_edition)

      publishing_api.put_content(guide.content_id, guide_for_publication.content_payload)
      publishing_api.patch_links(guide.content_id, guide_for_publication.links_payload)
      publishing_api.publish(guide.content_id, live_edition.update_type)
    end
  end

private

  attr_reader :guide, :publishing_api
end
