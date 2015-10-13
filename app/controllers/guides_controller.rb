class GuidesController < ApplicationController
  def new
    @guide = Guide.new
  end

  def create
    @guide = Guide.new(guide_params)
    @guide.latest_edition.state = edition_state_from_params
    if @guide.save
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
    @guide.attributes = guide_params
    @guide.latest_edition.state = edition_state_from_params
    if @guide.save
      redirect_to root_path, notice: "Guide has been updated"
    else
      render action: :edit
    end
  end

private

  def guide_params
    params.require(:guide).permit(:slug, latest_edition_attributes: [:title, :body])
  end

  def edition_state_from_params
    if params[:save_draft]
      'draft'
    elsif params[:publish]
      'published'
    end
  end
end
