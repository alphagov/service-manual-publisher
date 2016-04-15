class GuideFormPublicationPresenter
  def initialize(guide_form)
    @guide_for_publication = GuidePresenter.new(guide_form.guide, guide_form.edition)
  end

  delegate :content_id, :content_payload, :links_payload,
    to: :guide_for_publication

private

  attr_reader :guide_for_publication
end
