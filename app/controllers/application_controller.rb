class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include GDS::SSO::ControllerMethods
  before_filter :authenticate_user!

  def guide_preview_url(guide)
    frontend_host = Rails.env.production? ? Plek.find('draft-origin') : Plek.find('government-frontend')
    [frontend_host, guide.slug].join
  end
  helper_method :guide_preview_url
end
