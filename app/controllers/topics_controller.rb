class TopicsController < ApplicationController
  def index
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
    @topic.title = params[:topic][:title]
    @topic.description = params[:topic][:description]
    @topic.tree = JSON.parse(params[:topic][:tree])
    if @topic.save
      redirect_to topics_path, notice: "Topic has been updated"
    else
      render :new
    end
  end
end
