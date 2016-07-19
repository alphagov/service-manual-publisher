class TopicsController < ApplicationController
  def index
    @topics = Topic.all.order(updated_at: :desc)
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(create_topic_params)
    if params[:add_heading]
      @topic.topic_sections.build
      render :edit
      return
    end

    publication = TopicPublisher.new(content_model: @topic)
      .save_draft(TopicPresenter.new(@topic))

    respond_for_topic_publication publication, notice: "Topic has been created"
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    @topic.assign_attributes(update_topic_params)
    if params[:add_heading]
      @topic.topic_sections.build
      render :edit
      return
    end

    if params[:publish]
      publish
    else
      save_draft
    end
  end

private

  def publish
    publication = TopicPublisher.new(content_model: @topic)
      .publish

    if publication.success?
      GuideTaggerJob.batch_perform_later(@topic)
      TopicSearchIndexer.new(@topic).index

      redirect_to edit_topic_path(@topic), notice: "Topic has been published"
    else
      flash.now[:error] = publication.error
      render 'edit'
    end
  end

  def save_draft
    publication = TopicPublisher.new(content_model: @topic)
      .save_draft(TopicPresenter.new(@topic))

    respond_for_topic_publication publication, notice: "Topic has been updated"
  end

  def respond_for_topic_publication(publication, opts = {})
    success_notice = opts.fetch(:notice)

    if publication.success?
      redirect_to edit_topic_path(@topic), notice: success_notice
    else
      flash.now[:error] = publication.error
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
    [
      :title,
      :description,
      :visually_collapsed,
      content_owner_ids: [],
      topic_sections_attributes: [:id, :_destroy, :title, :description, :position]
    ]
  end
end
