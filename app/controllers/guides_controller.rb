class GuidesController < ApplicationController
  def index
    @guides = Guide.includes(latest_edition: :user)
  end

  def new
    @guide = Guide.new(
      latest_edition: Edition.new,
      slug:           "/service-manual/",
    )
  end

  def create
    @guide = Guide.new(guide_params)
    @guide.latest_edition.state = edition_state_from_params
    if @guide.save
      GuidePublisher.new(@guide).publish!
      redirect_to root_path, notice: "Guide has been created"
    else
      render action: :new
    end
  end

  def edit
    @guide = Guide.find(params[:id])
  end

  def update
    @guide = Guide.find(params[:id])
    if @guide.update_attributes_from_params(guide_params, state: edition_state_from_params)
      GuidePublisher.new(@guide).publish!
      redirect_to root_path, notice: "Guide has been updated"
    else
      render action: :edit
    end
  end

private

  def guide_params
    params[:guide][:latest_edition_attributes].merge!(user_id: current_user.id)
    params.require(:guide).permit(
      :slug,
      latest_edition_attributes: [
        :title, :body, :description, :publisher_title, :phase, :user_id,
        :related_discussion_href, :related_discussion_title, :update_type
      ])
  end

  def edition_state_from_params
    if params[:save_draft]
      'draft'
    elsif params[:publish]
      'published'
    end
  end
end
