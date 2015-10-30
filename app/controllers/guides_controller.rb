class GuidesController < ApplicationController
  def index
    @guides = Guide
                .includes(latest_edition: :user)
                .page(params[:page])
  end

  def new
    @guide = Guide.new(slug: "/service-manual/")
    @edition = Edition.new
  end

  def create
    @guide = Guide.new(guide_params)
    @edition = build_new_edition_version_for(@guide)
    if @guide.save
      GuidePublisher.new(guide: @guide, edition: @edition).process
      redirect_to root_path, notice: "Guide has been created"
    else
      render action: :new
    end
  rescue GdsApi::HTTPClientError => e
    flash[:error] = e.error_details["error"]["message"]
    render template: 'guides/new'
  end

  def edit
    @guide = Guide.find(params[:id])
    @edition = @guide.latest_edition.unsaved_copy
  end

  def update
    @guide = Guide.find(params[:id])
    @edition = build_new_edition_version_for(@guide)
    if @guide.update_attributes(guide_params)
      GuidePublisher.new(guide: @guide, edition: @edition).process
      redirect_to root_path, notice: "Guide has been updated"
    else
      render action: :edit
    end
  rescue GdsApi::HTTPClientError => e
    flash[:error] = e.error_details["error"]["message"]
    render template: 'guides/edit'
  end

private

  def build_new_edition_version_for(guide)
    template_edition = guide.latest_edition || Edition.new

    guide.editions.build(
      template_edition.copyable_attributes(
        state: edition_state_from_params,
        user_id: current_user.id
      ).merge(edition_params)
    )
  end

  def guide_params
    params.require(:guide).permit(:slug)
  end

  def edition_params
    params
      .require(:guide)
      .require(:edition)
      .permit(
        :title,
        :body,
        :description,
        :publisher_title,
        :phase,
        :related_discussion_href,
        :related_discussion_title,
        :update_type
      )
  end

  def edition_state_from_params
    if params[:save_draft]
      'draft'
    elsif params[:publish]
      'published'
    end
  end
end
