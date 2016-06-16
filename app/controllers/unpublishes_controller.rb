class UnpublishesController < ApplicationController
  def new
    @guide = Guide.find(params[:guide_id])
    @redirect = Redirect.new(old_path: @guide.slug)
    @select_options = select_options
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
      @select_options = select_options
      render :new
    end
  end

private

  def select_options
    guide_select_options = Guide
      .with_published_editions
      .order(:slug).pluck(:slug)
      .map { |g| [g, g] }
    topic_select_options = Topic
      .order(:path).pluck(:path)
      .map { |g| [g, g] }
    {
      "Other" => ["/service-manual"],
      "Topics" => topic_select_options,
      "Guides" => guide_select_options,
    }
  end
end
