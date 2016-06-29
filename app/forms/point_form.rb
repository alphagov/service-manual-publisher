class PointForm < BaseGuideForm
  def requires_topic?
    false
  end

  def slug_prefix
    "/service-manual/service-standard"
  end
end
