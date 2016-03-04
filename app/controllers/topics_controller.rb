class TopicsController < ApplicationController
  def index
    @topics = Topic.all.order(updated_at: :desc)
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(create_topic_params)

    publication = Publisher.new(content_model: @topic).
                            save_draft(TopicPresenter.new(@topic))
    if publication.success?
      redirect_to edit_topic_path(@topic), notice: "Topic has been created"
    else
      flash.now[:error] = publication.errors
      render 'new'
    end
  end

  def edit
    @topic = Topic.find(params[:id])
    render :new
  end

  def update
    @topic = Topic.find(params[:id])
    @topic.assign_attributes(update_topic_params)

    publisher = Publisher.new(content_model: @topic)

    if params[:publish]
      publication = publisher.publish

      if publication.success?
        redirect_to edit_topic_path(@topic), notice: "Topic has been published"
      else
        flash.now[:error] = publication.errors
        render 'new'
      end
    else
      publication = publisher.save_draft(TopicPresenter.new(@topic))

      if publication.success?
        redirect_to edit_topic_path(@topic), notice: "Topic has been updated"
      else
        flash.now[:error] = publication.errors
        render 'new'
      end
    end
  end

private

  def latest_editions
    @latest_editions ||= Guide.all.includes(:latest_edition).map(&:latest_edition).sort_by(&:title)
  end
  helper_method :latest_editions

  def create_topic_params
    params.require(:topic).permit(:path, *updatable_topic_attributes)
  end

  def update_topic_params
    params.require(:topic).permit(*updatable_topic_attributes)
  end

  def updatable_topic_attributes
    [:title, :description, :tree, content_owner_ids: []]
  end
end
