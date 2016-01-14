class TopicsController < ApplicationController
  before_action :instantiate_latest_editions, only: [:new, :edit]

  def index
    @topics = Topic.all.order(updated_at: :desc)
  end

  def new
    @topic = Topic.new
  end

  def create
    topic = Topic.new(params.require(:topic).permit(:path, :title, :description))
    topic.tree = JSON.parse(params[:topic][:tree])
    if topic.save
      redirect_to topics_path, notice: "Topic has been created"
    else
      render :new
    end
  end

  def edit
    @topic = Topic.find(params[:id])
    render :new
  end

  def update
    @topic = Topic.find(params[:id])
    @topic.attributes = params.require(:topic).permit(:title, :description)
    @topic.tree = JSON.parse(params[:topic][:tree])
    if @topic.save
      redirect_to topics_path, notice: "Topic has been updated"
    else
      render :new
    end
  end

private

  def instantiate_latest_editions
    @latest_editions = Guide.all.includes(:latest_edition).map(&:latest_edition)
  end
end
