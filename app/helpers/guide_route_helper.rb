module GuideRouteHelper
  def guide_frontend_published_url(guide)
    "#{Plek.new.website_root}#{guide.slug}"
  end
end
