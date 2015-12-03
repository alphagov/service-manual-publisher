class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include GDS::SSO::ControllerMethods
  before_filter :authenticate_user!

  def guide_preview_url(guide)
    [Plek.find('draft-origin'), guide.slug].join('')
  end
  helper_method :guide_preview_url

  helper_method :user_options
  def user_options
    @user_options ||= User.pluck(:name, :id)
  end

  helper_method :state_options
  def state_options
    @state_options ||= %w(draft published review_requested approved).map {|s| [s.titleize, s]}
  end

  helper_method :content_owner_options
  def content_owner_options
    @content_owner_options ||= ContentOwner.pluck(:title, :id)
  end

  def back_or_default(fallback_uri = root_url, anchor: nil)
    uri = if request.referrer.present? && request.referrer != request.url
      request.referrer
    else
      fallback_uri
    end
    if anchor && uri.exclude?("#")
      uri += "##{anchor}"
    end
    uri
  end
end
