class GuidesController < ApplicationController
  def index
    @user_options = User.pluck(:name, :id)
    @state_options = Edition::STATES.map { |s| [s.titleize, s] }

    # TODO: :content_owner not being included is resulting in an N+1 query
    @guides = Guide.includes(latest_edition: [:user])
                   .by_user(params[:user])
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
    @guide.build_latest_edition(update_type: 'major')
  end

  def create
    @guide = Guide.new(guide_params)
    @guide.latest_edition.version = 1

    publication = Publisher.new(content_model: @guide).
                            save_draft(GuidePresenter.new(@guide, @guide.latest_edition))
    if publication.success?
      redirect_to edit_guide_path(@guide), notice: 'Guide has been created'
    else
      flash.now[:error] = publication.error
      render 'new'
    end
  end

  def edit
    @guide = Guide.find(params[:id])
  end

  def update
    @guide = Guide.find(params[:id])

    # Build a new latest_edition without automatically saving it and without
    # nullifying the foreign key on the previous one
    #
    # Because latest_edition is a has_one association it has some perculiar
    # behaviour. #latest_edition=() will autosave the newly built record which we
    # do not want. #build_latest_edition() will nullify the foreign key on the
    # record being replaced because, fairly, Rails expects there to be only one
    # latest edition.
    #
    # We hack around the problem by reassigning the foreign key (guide_id) after
    # building the new latest edition. The latest_edition association is causing
    # confusion across the app so this hack can be removed if/when it is
    # replaced. We also reset the updated_at column because this isn't a valid
    # reason to update it.
    previous_latest_edition = @guide.latest_edition
    guide_id = previous_latest_edition.guide_id
    updated_at = previous_latest_edition.updated_at
    @guide.build_latest_edition(@guide.latest_edition.dup.attributes)
    previous_latest_edition.update_columns(guide_id: guide_id, updated_at: updated_at)

    if previous_latest_edition.published?
      @guide.latest_edition.version += 1
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
      @edition = @guide.latest_edition
      flash[:error] = "This guide could not be published because it is not included in a topic page."
      render template: 'guides/edit'
      return
    end

    @guide.latest_edition.assign_attributes(state: 'published')

    publication = Publisher.new(content_model: @guide).publish
    if publication.success?
      index_for_search(@guide)

      unless @guide.latest_edition.notification_subscribers == [current_user]
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
    @guide.assign_attributes(guide_params)

    publication = Publisher.new(content_model: @guide).
                            save_draft(GuidePresenter.new(@guide, @guide.latest_edition))
    if publication.success?
      redirect_to edit_guide_path(@guide), notice: "Guide has been updated"
    else
      flash.now[:error] = publication.error
      render 'edit'
    end
  end

  def guide_params(with = {})
    default_params = {
      latest_edition_attributes: { state: 'draft', user: current_user }
    }
    with = default_params.deep_merge(with)

    params
      .require(:guide)
      .permit(:slug, :type, latest_edition_attributes: [
        :title,
        :body,
        :description,
        :content_owner_id,
        :related_discussion_href,
        :related_discussion_title,
        :update_type,
        :change_note,
        :change_summary,
      ]).deep_merge(with)
  end

  def index_for_search(guide)
    SearchIndexer.new(guide).index
  rescue => e
    notify_airbrake(e)
    Rails.logger.error(e.message)
  end
end
