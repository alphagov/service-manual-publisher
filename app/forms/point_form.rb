class PointForm < GuideForm
  def requires_topic?
    false
  end

  def slug_prefix
    "/service-manual/service-standard"
  end

  def save
    set_guide_attributes
    set_edition_attributes

    catching_gds_api_exceptions do
      if valid? && guide.save
        save_draft_to_publishing_api

        true
      else
        promote_errors_for(guide)
        promote_errors_for(edition)

        false
      end
    end
  end
end
