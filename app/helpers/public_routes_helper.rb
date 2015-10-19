module PublicRoutesHelper
  def document_preview_url(document)
    frontend_host = Rails.env.production? ? Plek.find('draft-origin') : Plek.find('government-frontend')
    [frontend_host, document.slug].join
  end
end
