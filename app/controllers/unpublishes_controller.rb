class UnpublishesController < ApplicationController
  def new
    @guide = Guide.find(params[:guide_id])
    @redirect = Redirect.new(old_path: @guide.slug)
  end

  def create
    @guide = Guide.find(params[:guide_id])
    @redirect = Redirect.new(
      params.require(:redirect).permit(:new_path)
    )
    @redirect.old_path = @guide.slug

    if @redirect.save
      edition = @guide.editions.build(@guide.latest_edition.dup.attributes)
      edition.state = "unpublished"
      edition.created_by = current_user
      edition.save!
      RedirectPublisher.new.process(
        content_id: @redirect.content_id,
        old_path:   @redirect.old_path,
        new_path: @redirect.new_path,
      )
      GuideSearchIndexer.new(@guide).delete
      redirect_to root_path
    else
      render :new
    end
  end
end
