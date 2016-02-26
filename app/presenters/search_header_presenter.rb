class SearchHeaderPresenter
  attr_reader :params, :current_user

  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def to_s
    [ownership, state, "guides", match, published_by].compact.join(" ")
  end

  def search?
    [:user, :state, :content_owner, :q].any? { |field| params[field].present? }
  end

  def ownership
    if params[:user].to_i == current_user.id
      "My"
    elsif params[:user].present?
      "#{User.find(params[:user]).name}'s"
    else
      "Everyone's"
    end
  end

  def state
    params[:state].to_s.humanize.downcase.presence
  end

  def match
    "matching \"#{params[:q]}\"" if params[:q].present?
  end

  def published_by
    if params[:content_owner].present?
      "published by #{GuideCommunity.find(params[:content_owner]).title}"
    end
  end
end
