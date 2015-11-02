class GuidesController < ApplicationController
  def index
    @guides = Guide
                .includes(latest_edition: :user)
                .order(updated_at: :desc)
                .page(params[:page])
  end

  def new
    @guide = Guide.new(slug: "/service-manual/")
    @guide.latest_edition = @guide.editions.build
  end

  def create
    @guide = Guide.new(guide_params)
    @guide.latest_edition.state = "draft"
    @guide.latest_edition.user = current_user

    ActiveRecord::Base.transaction do
      if @guide.save
        GuidePublisher.new(guide: @guide).process
        redirect_to success_url(@guide), notice: "Guide has been created"
      else
        render action: :new
      end
    end
  rescue GdsApi::HTTPClientError => e
    flash[:error] = e.error_details["error"]["message"]
    render template: 'guides/new'
  end

  def edit
    @guide = Guide.find(params[:id])
    @comments = comments_list(@guide)
    @new_comment = @guide.latest_edition.comments.build
  end

  def update
    @guide = Guide.find(params[:id])
    @comments = comments_list(@guide)
    @new_comment = @guide.latest_edition.comments.build

    ActiveRecord::Base.transaction do
      if @guide.update_attributes(guide_params({latest_edition_attributes: {state: edition_state_from_params, user_id: current_user.id}}))
        GuidePublisher.new(guide: @guide).process
        redirect_to success_url(@guide), notice: "Guide has been updated"
      else
        render action: :edit
      end
    end
  rescue GdsApi::HTTPClientError => e
    flash[:error] = e.error_details["error"]["message"]
    render template: 'guides/edit'
  end

private

  def success_url(guide)
    if params[:save_draft_and_preview]
      frontend_host = Rails.env.production? ? Plek.find('draft-origin') : Plek.find('government-frontend')
      [frontend_host, guide.slug].join
    else
      root_url
    end
  end

  def comments_list(guide)
    guide.latest_edition.comments
      .order(created_at: :asc)
      .includes(:user)
  end

  def guide_params(with={})
    params
      .require(:guide)
      .permit(:slug, latest_edition_attributes: [
        :title,
        :body,
        :description,
        :publisher_title,
        :phase,
        :related_discussion_href,
        :related_discussion_title,
        :update_type
      ]).deep_merge(with)
  end

  def edition_state_from_params
    if params[:publish]
      'published'
    else
      'draft'
    end
  end
end
