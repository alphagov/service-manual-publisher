module GuideRouteHelper
  def guide_frontend_published_url(guide)
    "#{Plek.find('www')}#{guide.slug}"
  end
end
