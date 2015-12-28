class GuidesController < ApplicationController
  def index
    @user_options = User.pluck(:name, :id)
    @state_options = %w(draft published review_requested approved).map {|s| [s.titleize, s]}
    @content_owner_options = ContentOwner.pluck(:title, :id)

    @guides = Guide.includes(latest_edition: [:user, :content_owner])

    if params[:user].present?
      @guides = @guides.where(editions: {user_id: params[:user]})
    end

    if params[:state].present?
      @guides = @guides.where(editions: {state: params[:state]})
    end

    if params[:content_owner].present?
      @guides = @guides.where(editions: {content_owner_id: params[:content_owner]})
    end

    if params[:q].present?
      @guides = @guides.search(params[:q])
    else
      @guides = @guides.order(updated_at: :desc)
    end

    @guides = @guides.page(params[:page])
  end

  def new
    @guide = Guide.new(slug: "/service-manual/")
    @guide.build_latest_edition(update_type: 'major')
  end

  def create
    @guide = Guide.new(guide_params)

    ActiveRecord::Base.transaction do
      if @guide.save
        GuidePublisher.new(guide: @guide).put_draft
        redirect_to edit_guide_path(@guide), notice: "Guide has been created"
      else
        render action: :new
      end
    end
  rescue GdsApi::HTTPErrorResponse => e
    flash[:error] = e.error_details["error"]["message"]
    render template: 'guides/new'
  end

  def edit
    @guide = Guide.find(params[:id])
  end

  def update
    @guide = Guide.find(params[:id])

    if params[:send_for_review].present?
      return send_for_review
    elsif params[:publish].present?
      return publish
    elsif params[:approve_for_publication].present?
      return approve_for_publication
    end

    @guide.ensure_draft_exists

    ActiveRecord::Base.transaction do
      if @guide.update_attributes(guide_params(latest_edition_attributes: { id: @guide.latest_edition.id }))
        GuidePublisher.new(guide: @guide).put_draft
        redirect_to success_url(@guide), notice: "Guide has been updated"
      else
        render action: :edit
      end
    end
  rescue GdsApi::HTTPErrorResponse => e
    flash[:error] = e.error_details["error"]["message"]
    render template: 'guides/edit'
  end

private

  def send_for_review
    @guide.latest_edition.state = 'review_requested'
    @guide.latest_edition.save!
    redirect_to back_or_default, notice: "A review has been requested"
  end

  def approve_for_publication
    edition = @guide.latest_edition
    edition.build_approval(user: current_user)
    edition.state = "approved"
    edition.save!
    NotificationMailer.approved_for_publishing(edition).deliver_later
    redirect_to back_or_default, notice: "Thanks for approving this guide"
  end

  def publish
    if ENV['DISABLE_PUBLISHING']
      @edition = @guide.latest_edition
      flash[:error] = "Publishing is currently disabled. The guide has not been published."
      return render template: 'editions/show'
    end

    ActiveRecord::Base.transaction do
      @guide.latest_edition.update_attributes!(state: 'published')
      GuidePublisher.new(guide: @guide).publish
      index_for_search(@guide)
      redirect_to back_or_default, notice: "Guide has been published"
    end
  rescue GdsApi::HTTPErrorResponse => e
    flash[:error] = e.error_details["error"]["message"]
    @guide = @guide.reload
    @edition = @guide.latest_edition
    render template: 'editions/show'
  end

  def success_url(guide)
    if params[:save_and_preview]
      guide_preview_url(guide)
    else
      back_or_default
    end
  end

  def guide_params(with = {})
    default_params = {
      latest_edition_attributes: { state: 'draft', user: current_user }
    }
    with = default_params.deep_merge(with)

    params
      .require(:guide)
      .permit(:slug, latest_edition_attributes: [
        :title,
        :body,
        :description,
        :content_owner_id,
        :related_discussion_href,
        :related_discussion_title,
        :update_type,
        :change_note,
        :change_summary,
      ]).deep_merge(with)
  end

  def index_for_search(guide)
    SearchIndexer.new(guide).index
  rescue => e
    notify_airbrake(e)
    Rails.logger.error(e.message)
  end
end
