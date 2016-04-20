class GuideCommunity < Guide
  def requires_content_owner?
    false
  end

  def requires_summary?
    false
  end
end
