class TopicsController < ApplicationController
  def index
    @topics = Topic.all.order(updated_at: :desc)
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params.require(:topic).permit(:path, :title, :description, content_owner_ids: []))
    @topic.tree = JSON.parse(params[:topic][:tree])

    ActiveRecord::Base.transaction do
      if @topic.save
        redirect_to edit_topic_path(@topic), notice: "Topic has been created"
      else
        render :new
      end
    end
  rescue GdsApi::HTTPErrorResponse => e
    flash[:error] = e.error_details.fetch("error", {})["message"]
    render :new
  end

  def edit
    @topic = Topic.find(params[:id])
    render :new
  end

  def update
    @topic = Topic.find(params[:id])
    @topic.attributes = params.require(:topic).permit(:title, :description, content_owner_ids: [])
    @topic.tree = JSON.parse(params[:topic][:tree])

    if params[:publish]
      ActiveRecord::Base.transaction do
        if @topic.save
          TopicPublisher.new(@topic).publish
          redirect_to topics_path, notice: "Topic has been published"
        else
          render :new
        end
      end
    else
      ActiveRecord::Base.transaction do
        if @topic.save
          TopicPublisher.new(@topic).publish_immediately
          redirect_to topics_path, notice: "Topic has been updated"
        else
          render :new
        end
      end
    end
  rescue GdsApi::HTTPErrorResponse => e
    flash[:error] = e.error_details.fetch("error", {})["message"]
    render :new
  end

private

  def latest_editions
    @latest_editions ||= Guide.all.includes(:latest_edition).map(&:latest_edition).sort_by(&:title)
  end
  helper_method :latest_editions
end
