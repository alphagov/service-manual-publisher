module PublicRoutesHelper
  def document_preview_url(base_path)
    frontend_host = Rails.env.production? ? Plek.new.external_url_for("draft-origin") : Plek.new.external_url_for("government-frontend")
    [frontend_host, base_path].join
  end
end
