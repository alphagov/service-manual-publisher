class Point < Guide
  def requires_content_owner?
    false
  end

  def requires_summary?
    true
  end
end
