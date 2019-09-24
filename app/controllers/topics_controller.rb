class TopicsController < ApplicationController
  before_action :find_topic, only: [:edit, :update]

  def index
    @topics = Topic.all.order(updated_at: :desc)
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(create_topic_params)

    if params[:add_heading]
      add_heading(@topic)
    else
      topic_respond_with save_draft(@topic), notice: "Topic has been created"
    end
  end

  def edit
  end

  def update
    if params[:add_heading]
      @topic.assign_attributes(update_topic_params)
      add_heading(@topic)
    elsif params[:publish]
      topic_respond_with publish(@topic), notice: "Topic has been published"
    else
      @topic.assign_attributes(update_topic_params)
      topic_respond_with save_draft(@topic), notice: "Topic has been updated"
    end
  end

private

  def find_topic
    @topic = Topic.includes(topic_sections: [topic_section_guides: :guide]).find(params[:id])
  end

  def save_draft(topic)
    TopicPublisher.new(topic: topic).save_draft
  end

  def publish(topic)
    TopicPublisher.new(topic: topic).publish
  end

  def add_heading(topic)
    topic.topic_sections.build(position: next_position_in_list(@topic))

    render "edit"
  end

  def topic_respond_with(response, opts = {})
    success_notice = opts.fetch(:notice)

    if response.success?
      redirect_to edit_topic_path(@topic), notice: success_notice
    else
      flash.now[:error] = response.error
      render @topic.persisted? ? "edit" : "new"
    end
  end

  def next_position_in_list(topic)
    highest_position_in_list(topic) + 1
  end

  def highest_position_in_list(topic)
    topic.topic_sections.map(&:position).max || 0
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
      :include_on_homepage,
      content_owner_ids: [],
      topic_sections_attributes: [
        :id,
        :_destroy,
        :title,
        :description,
        :position,
        topic_section_guides_attributes: [
          :id,
          :position
        ]
      ]
    ]
  end
end
