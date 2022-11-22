module GuideRouteHelper
  def guide_frontend_published_url(guide)
    "#{Plek.website_root}#{guide.slug}"
  end
end
