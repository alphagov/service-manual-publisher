class ServiceStandardPresenter
  def initialize(points)
    @points = points
  end

  def content_id
    "00f693d4-866a-4fe6-a8d6-09cd7db8980b"
  end

  def links_payload
    {
      links: {
        points: points.map(&:content_id)
      }
    }
  end

private

  attr_reader :points
end
