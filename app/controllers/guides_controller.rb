class GuidesController < ApplicationController
  def index
    @guides = if params[:q].present?
                Guide.search(params[:q])
                  .includes(latest_edition: :user)
                  .page(params[:page])
              elsif params[:state].present?
                @guides = Guide
                            .with_state(params[:state])
                            .page(params[:page])
              else
                Guide
                  .includes(latest_edition: :user)
                  .page(params[:page])
                  .order(updated_at: :desc)
              end
    @states_and_counts = %w(draft published review_requested approved).map do |s|
      OpenStruct.new(value: s, count: Guide.with_state(s).count)
    end
  end

  def new
    @guide = Guide.new(slug: "/service-manual/")
    @guide.build_latest_edition
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

    @guide.ensure_draft_exists

    ActiveRecord::Base.transaction do
      if @guide.update_attributes(guide_params(latest_edition_attributes: { id: @guide.latest_edition.id }))
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
