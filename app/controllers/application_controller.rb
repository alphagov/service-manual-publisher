class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include GDS::SSO::ControllerMethods
  before_action :require_signin_permission!
  before_action :set_authenticated_user_header

  def preview_content_model_url(content_model)
    [Plek.new.external_url_for('draft-origin'), content_model.slug].join('')
  end
  helper_method :preview_content_model_url

  def set_authenticated_user_header
    if current_user && GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user].nil?
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
    end
  end
end
