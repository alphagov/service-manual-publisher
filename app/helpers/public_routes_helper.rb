module PublicRoutesHelper
  def document_preview_url(base_path)
    frontend_host = Rails.env.production? ? Plek.find('draft-origin') : Plek.find('service-manual-frontend')
    [frontend_host, base_path].join
  end
end
