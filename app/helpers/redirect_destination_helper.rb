module RedirectDestinationHelper
  def redirect_destination_select_options
    {
      "Other" => ["/service-manual", "/service-manual/service-standard"],
      "Topics" => topic_select_options,
      "Guides" => guide_select_options,
    }
  end

private

  def guide_select_options
    Guide.live.order(:slug).pluck(:slug)
  end

  def topic_select_options
    Topic.order(:path).pluck(:path)
  end
end
