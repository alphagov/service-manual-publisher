class GuidesController < ApplicationController
  def index
    scope = Guide.all
    @guides = GuidesFilter.new(scope).by(params)
  end

  def new
    type = params[:type].presence_in(%w{ GuideCommunity Point })

    @guide_form = GuideForm.new(
      guide: Guide.new(type: type),
      edition: Edition.new,
      user: current_user,
      )
  end

  def create
    guide = Guide.new(type: guide_form_params[:type])
    edition = guide.editions.build
    @guide_form = GuideForm.new(
      guide: guide,
      edition: edition,
      user: current_user,
      )
    @guide_form.assign_attributes(guide_form_params)

    publication = Publisher.new(content_model: @guide_form)
                    .save_draft(GuideFormPublicationPresenter.new(@guide_form))
    if publication.success?
      redirect_to edit_guide_path(@guide_form), notice: 'Guide has been created'
    else
      flash.now[:error] = publication.error
      render 'new'
    end
  end

  def edit
    guide = Guide.find(params[:id])
    edition = guide.latest_edition

    @guide_form = GuideForm.new(
      guide: guide,
      edition: edition,
      user: current_user
      )
  end

  def update
    guide = Guide.find(params[:id])
    edition = guide.editions.build(guide.latest_edition.dup.attributes)
    edition.created_by = current_user

    @guide_form = GuideForm.new(
      guide: guide,
      edition: edition,
      user: current_user
      )

    if params[:send_for_review].present?
      send_for_review(guide, edition)
    elsif params[:approve_for_publication].present?
      approve_for_publication(guide, edition)
    elsif params[:publish].present?
      publish
    elsif params[:discard].present?
      discard
    else
      save_draft
    end
  end

private

  def send_for_review(guide, edition)
    edition.state = 'review_requested'
    edition.created_by = current_user
    edition.save!

    redirect_to edit_guide_path(guide), notice: "A review has been requested"
  end

  def approve_for_publication(guide, edition)
    edition.build_approval(user: current_user)
    edition.created_by = current_user
    edition.state = "ready"
    edition.save!

    NotificationMailer.ready_for_publishing(guide).deliver_later

    redirect_to edit_guide_path(guide), notice: "Thanks for approving this guide"
  end

  def publish
    @guide_form.edition.assign_attributes(state: 'published')

    publication = Publisher.new(content_model: @guide_form.guide).publish
    if publication.success?
      index_for_search(@guide_form.guide)

      unless @guide_form.edition.notification_subscribers == [current_user]
        NotificationMailer.published(@guide_form.guide, current_user).deliver_later
      end

      redirect_to edit_guide_path(@guide_form), notice: "Guide has been published"
    else
      flash.now[:error] = publication.error
      render 'edit'
    end
  end

  def discard
    discard_draft = Publisher.new(content_model: @guide_form.guide)
      .discard_draft
    if discard_draft.success?
      redirect_to root_path, notice: "Draft has been discarded"
    else
      flash.now[:error] = discard_draft.error
      render 'edit'
    end
  end

  def save_draft
    @guide_form.assign_attributes(guide_form_params)

    publication = Publisher.new(content_model: @guide_form)
                    .save_draft(GuideFormPublicationPresenter.new(@guide_form))
    if publication.success?
      redirect_to edit_guide_path(@guide_form), notice: "Guide has been updated"
    else
      flash.now[:error] = publication.error
      render 'edit'
    end
  end

  def guide_form_params
    params.fetch(:guide, {})
  end

  def index_for_search(guide)
    GuideSearchIndexer.new(guide).index
  rescue => e
    notify_airbrake(e)
    Rails.logger.error(e.message)
  end

  class GuidesFilter
    VALID_FILTERS = [
      'author',
      'content_owner',
      'page',
      'page_type',
      'q',
      'state'
    ]

    def initialize(scope)
      @scope = scope
      # TODO: :content_owner not being included is resulting in an N+1 query
      @scope = @scope.includes(editions: [:author]).references(:editions)
      @scope = @scope.order(updated_at: :desc)
      @scope = @scope.page(1)
    end

    def by(params)
      params.slice(*VALID_FILTERS).each do |key, param|

        next if param.blank?

        case key
        when 'author'
          @scope = @scope.by_author(param)
        when 'content_owner'
          @scope = @scope.owned_by(param)
        when 'page'
          @scope = @scope.page(param)
        when 'page_type'
          apply_type_scope(param)
        when 'q'
          @scope = @scope.search(param)
        when 'state'
          @scope = @scope.in_state(param)
        end
      end

      @scope
    end

  private

    def apply_type_scope(type)
      case type
      when 'All'
        @scope = @scope
      when 'Guide'
        @scope = @scope.by_type(nil)
      else
        @scope = @scope.by_type(type)
      end
    end
  end
end
