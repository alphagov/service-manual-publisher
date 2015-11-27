class GuidesController < ApplicationController
  def index
    @state_titles = {
      draft: "Edit",
      review_requested: "Review guide",
      approved: "Publish",
      published: "Edit",
    }
    @user_options = User.all.collect{ |u| [u.name, u.id] }
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
        redirect_to success_url(@guide), notice: "Guide has been created"
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
    @comments = @guide.comments_for_rendering
  end

  def update
    @guide = Guide.find(params[:id])
    @comments = @guide.comments_for_rendering

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

  def success_url(guide)
    if params[:save_draft_and_preview]
      guide_preview_url(guide)
    else
      back_or_default
    end
  end

  def comments_list(guide)
    guide.latest_edition.comments
      .order(created_at: :asc)
      .includes(:user)
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
      ]).deep_merge(with)
  end
end
