module RedirectDestinationHelper
  def redirect_destination_select_options
    guide_select_options = Guide
      .live
      .order(:slug).pluck(:slug)

    topic_select_options = Topic
      .order(:path).pluck(:path)

    {
      "Other" => ["/service-manual", "/service-manual/service-standard"],
      "Topics" => topic_select_options,
      "Guides" => guide_select_options,
    }
  end
end
