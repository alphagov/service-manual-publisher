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

    respond_for_topic_publication publication, notice: "Topic has been created"
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    @topic.assign_attributes(update_topic_params)

    publisher = Publisher.new(content_model: @topic)

    if params[:publish]
      publication = publisher.publish

      respond_for_topic_publication publication, notice: "Topic has been published"
    else
      publication = publisher.save_draft(TopicPresenter.new(@topic))

      respond_for_topic_publication publication, notice: "Topic has been updated"
    end
  end

private

  def respond_for_topic_publication(publication, opts = {})
    success_notice = opts.fetch(:notice)

    if publication.success?
      redirect_to edit_topic_path(@topic), notice: success_notice
    else
      flash.now[:error] = publication.errors
      render @topic.persisted? ? 'edit' : 'new'
    end
  end

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
