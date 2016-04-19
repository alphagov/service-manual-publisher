class TopicsController < ApplicationController
  def index
    @topics = Topic.all.order(updated_at: :desc)
  end

  def new
    @topic = Topic.new
    @topic_tree = [].to_json
  end

  def create
    @topic = Topic.new(create_topic_params)
    store_topic_sections_in_topic

    publication = Publisher.new(content_model: @topic).
                            save_draft(TopicPresenter.new(@topic))

    respond_for_topic_publication publication, notice: "Topic has been created"
  end

  def edit
    @topic = Topic.find(params[:id])
    @topic_tree = @topic.topic_sections.map do |topic_section|
      {
        title: topic_section.title,
        description: topic_section.description,
        guides: topic_section.guides.pluck(:id),
      }
    end.to_json
  end

  def update
    @topic = Topic.find(params[:id])
    @topic.assign_attributes(update_topic_params)
    store_topic_sections_in_topic

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
      GuideTaggerJob.batch_perform_later(@topic)
      TopicSearchIndexer.new(@topic).index

      redirect_to edit_topic_path(@topic), notice: "Topic has been published"
    else
      flash.now[:error] = publication.error
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
    [:title, :description, content_owner_ids: []]
  end

  def store_topic_sections_in_topic
    @topic.topic_sections.destroy_all
    JSON.parse(params[:topic][:tree]).each do |t|
      topic_section = @topic.topic_sections.build(
        title: t["title"],
        description: t["description"],
      )
      t["guides"].each do |guide_id|
        topic_section.topic_section_guides.build(
          guide: Guide.find(guide_id)
        )
      end
    end
  end
end
