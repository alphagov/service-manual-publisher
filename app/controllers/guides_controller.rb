class GuidesController < ApplicationController
  def index
    @user_options = User.pluck(:name, :id)
    @state_options = %w(draft published review_requested approved).map { |s| [s.titleize, s] }

    @guides = Guide.includes(latest_edition: [:user, :content_owner])
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

    publication = Publisher.new(content_model: @guide).
                            save_draft(GuidePresenter.new(@guide, @guide.latest_edition))
    if publication.success?
      redirect_to edit_guide_path(@guide), notice: 'Guide has been created'
    else
      flash.now[:error] = publication.errors
      render 'new'
    end
  end

  def edit
    @guide = Guide.find(params[:id])
  end

  def update
    @guide = Guide.find(params[:id])

    if params[:send_for_review].present?
      send_for_review
    elsif params[:approve_for_publication].present?
      approve_for_publication
    elsif params[:publish].present?
      publish
    else
      save_draft
    end
  end

private

  def send_for_review
    ApprovalProcess.new(content_model: @guide).request_review

    redirect_to back_or_default, notice: "A review has been requested"
  end

  def approve_for_publication
    ApprovalProcess.new(content_model: @guide).give_approval(approver: current_user)

    redirect_to back_or_default, notice: "Thanks for approving this guide"
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

      redirect_to back_or_default, notice: "Guide has been published"
    else
      @guide = @guide.reload

      flash.now[:error] = publication.errors
      render 'edit'
    end
  end

  def save_draft
    @guide.ensure_draft_exists
    @guide.assign_attributes(guide_params(latest_edition_attributes: { id: @guide.latest_edition.id }))

    publication = Publisher.new(content_model: @guide).
                            save_draft(GuidePresenter.new(@guide, @guide.latest_edition))
    if publication.success?
      redirect_to success_url(@guide), notice: "Guide has been updated"
    else
      flash.now[:error] = publication.errors
      render 'edit'
    end
  end

  def success_url(guide)
    if params[:save_and_preview]
      preview_content_model_url(guide)
    else
      back_or_default
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
