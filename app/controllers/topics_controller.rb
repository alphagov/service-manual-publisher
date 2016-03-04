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

    if params[:publish]
      publish
    else
      save_draft
    end
  end

private

  def publish
    publication = Publisher.new(content_model: @topic).
                            publish

    if publication.success?
      GuideTaggerJob.batch_perform_later(
        guide_ids: @topic.guide_ids,
        topic_id: @topic.content_id
      )
      TopicSearchIndexer.new(@topic).index

      redirect_to edit_topic_path(@topic), notice: "Topic has been published"
    else
      flash.now[:error] = publication.errors
      render 'edit'
    end
  end

  def save_draft
    publication = Publisher.new(content_model: @topic).
                            save_draft(TopicPresenter.new(@topic))

    respond_for_topic_publication publication, notice: "Topic has been updated"
  end

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
