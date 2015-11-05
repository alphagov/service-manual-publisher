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
    # Temporarily set latest_edition manually.
    # (There's always only one edition at this point)
    @guide.latest_edition = @guide.editions.first
    @guide.latest_edition.state = "draft"
    @guide.latest_edition.user = current_user

    ActiveRecord::Base.transaction do
      if @guide.save
        GuidePublisher.new(guide: @guide).put_draft
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
    @comments = @guide.comments_for_rendering
  end

  def update
    @guide = Guide.find(params[:id])
    @comments = @guide.comments_for_rendering

    ActiveRecord::Base.transaction do
      if @guide.update_attributes(guide_params(editions_attributes: { "0" => {state: 'draft', user_id: current_user.id}}))
        GuidePublisher.new(guide: @guide).put_draft
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
      guide_preview_url(guide)
    elsif request.referrer.present? && request.referrer != request.url
      request.referrer
    else
      root_url
    end
  end

  def comments_list(guide)
    guide.latest_edition.comments
      .order(created_at: :asc)
      .includes(:user)
  end

  def guide_params(with = {})
    params
      .require(:guide)
      .permit(:slug, editions_attributes: [
        :id,
        :title,
        :body,
        :description,
        :publisher_title,
        :phase,
        :related_discussion_href,
        :related_discussion_title,
        :update_type,
        :change_note,
      ]).deep_merge(with)
  end
end
