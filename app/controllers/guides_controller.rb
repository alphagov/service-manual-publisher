class GuidesController < ApplicationController
  def index
    @state_options = Edition::STATES.map { |s| [s.titleize, s] }

    # TODO: :content_owner not being included is resulting in an N+1 query
    @guides = Guide.includes(editions: [:author]).references(:editions)
                   .by_author(params[:author])
                   .in_state(params[:state])
                   .owned_by(params[:content_owner])
                   .page(params[:page])

    if params[:q].present?
      @guides = @guides.search(params[:q])
    else
      @guides = @guides.order(updated_at: :desc)
    end
  end

  def new
    type = params[:community].present? ? 'GuideCommunity' : nil
    @guide = Guide.new(slug: "/service-manual/", type: type)
    @edition = @guide.editions.build(update_type: 'major')
  end

  def create
    @edition = Edition.new(edition_params)
    @edition.version = 1
    @edition.author = current_user
    @guide = Guide.new(guide_params)
    @guide.editions << @edition

    publication = Publisher.new(content_model: @guide).
                            save_draft(GuidePresenter.new(@guide, @edition))
    if publication.success?
      redirect_to edit_guide_path(@guide), notice: 'Guide has been created'
    else
      flash.now[:error] = publication.error
      render 'new'
    end
  end

  def edit
    @guide = Guide.find(params[:id])
    @edition_author_id = current_user.id if @guide.latest_edition.published?
    @edition = @guide.latest_edition

    # If the most recent edition/version was published then by editing the user
    # is starting work on a new draft
    if @edition.published?
      @edition.update_type = "major"
      @edition.change_note = nil
      @edition.change_summary = nil
    end
  end

  def update
    @guide = Guide.find(params[:id])
    @edition_author_id = current_user.id if @guide.latest_edition.published?
    @edition = @guide.editions.build(@guide.latest_edition.dup.attributes)

    if @edition.published?
      @edition.version += 1
    end

    if params[:send_for_review].present?
      send_for_review
    elsif params[:approve_for_publication].present?
      approve_for_publication
    elsif params[:publish].present?
      publish
    elsif params[:discard].present?
      discard
    else
      save_draft
    end
  end

private

  def send_for_review
    ApprovalProcess.new(content_model: @guide).request_review

    redirect_to edit_guide_path(@guide), notice: "A review has been requested"
  end

  def approve_for_publication
    ApprovalProcess.new(content_model: @guide).give_approval(approver: current_user)

    redirect_to edit_guide_path(@guide), notice: "Thanks for approving this guide"
  end

  def publish
    unless @guide.included_in_a_topic?
      flash[:error] = "This guide could not be published because it is not included in a topic page."
      render 'edit'
      return
    end

    @edition.assign_attributes(state: 'published')

    publication = Publisher.new(content_model: @guide).publish
    if publication.success?
      index_for_search(@guide)

      unless @edition.notification_subscribers == [current_user]
        NotificationMailer.published(@guide, current_user).deliver_later
      end

      redirect_to edit_guide_path(@guide), notice: "Guide has been published"
    else
      @guide = @guide.reload

      flash.now[:error] = publication.error
      render 'edit'
    end
  end

  def discard
    discard_draft = Publisher.new(content_model: @guide)
      .discard_draft
    if discard_draft.success?
      redirect_to root_path, notice: "Draft has been discarded"
    else
      flash.now[:error] = discard_draft.error
      render 'edit'
    end
  end

  def save_draft
    @edition.assign_attributes(edition_params)

    publication = Publisher.new(content_model: @guide).
                            save_draft(GuidePresenter.new(@guide, @guide.latest_edition))
    if publication.success?
      redirect_to edit_guide_path(@guide), notice: "Guide has been updated"
    else
      flash.now[:error] = publication.error
      render 'edit'
    end
  end

  def guide_params
    params
      .require(:guide)
      .permit(:slug, :type)
  end

  def edition_params
    permitted_attributes = [
      :title,
      :body,
      :description,
      :content_owner_id,
      :related_discussion_href,
      :related_discussion_title,
      :update_type,
      :change_note,
      :change_summary,
    ]
    default_params = { state: 'draft', user: current_user }

    params
      .require(:guide)
      .require(:edition)
      .permit(permitted_attributes)
      .merge(default_params)
  end

  def index_for_search(guide)
    SearchIndexer.new(guide).index
  rescue => e
    notify_airbrake(e)
    Rails.logger.error(e.message)
  end
end
