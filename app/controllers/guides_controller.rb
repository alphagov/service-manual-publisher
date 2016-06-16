class GuidesController < ApplicationController
  def index
    scope = Guide.all
    @guides = GuidesFilter.new(scope).by(params)
  end

  def new
    type = params[:type].presence_in(%w{ GuideCommunity Point })
    guide = Guide.new(type: type)

    @guide_form = GuideForm.new(
      guide: guide,
      edition: Edition.new,
      user: current_user,
    )
  end

  def create
    guide = Guide.new(type: guide_form_params[:type])

    save(guide)
  end

  def edit
    guide = Guide.find(params[:id])

    @guide_form = GuideForm.new(
      guide: guide,
      edition: guide.latest_edition,
      user: current_user
    )
  end

  def update
    guide = Guide.find(params[:id])

    if params[:send_for_review].present?
      manage!(guide, :request_review, message: "A review has been requested")
    elsif params[:approve_for_publication].present?
      manage!(guide, :approve_for_publication, message: "Thanks for approving this guide")
    elsif params[:publish].present?
      manage(guide, :publish, message: "Guide has been published")
    elsif params[:discard].present?
      manage(guide, :discard_draft, message: "Draft has been discarded", redirect: root_path)
    else
      save(guide)
    end
  end

private

  def manage!(guide, action, opts = {})
    message = opts.fetch(:message, nil)

    guide_manager = GuideManager.new(guide: guide, user: current_user)
    guide_manager.public_send("#{action}!")

    redirect_to edit_guide_path(guide), notice: message
  end

  def manage(guide, action, opts = {})
    redirect = opts.fetch(:redirect, edit_guide_path(guide))
    message = opts.fetch(:message, nil)

    guide_manager = GuideManager.new(guide: guide, user: current_user)
    result = guide_manager.public_send(action)

    if result.success?
      redirect_to redirect, notice: message
    else
      @guide_form = GuideForm.new(
        guide: guide,
        edition: guide.latest_edition,
        user: current_user
      )

      flash.now[:error] = result.errors
      render 'edit'
    end
  end

  def save(guide)
    failure_template = guide.persisted? ? 'edit' : 'new'

    @guide_form = GuideForm.new(
      guide: guide,
      edition: guide.editions.build(created_by: current_user),
      user: current_user
    )
    @guide_form.assign_attributes(guide_form_params)

    if @guide_form.save
      redirect_to edit_guide_path(@guide_form), notice: "Guide has been saved"
    else
      flash.now[:error] = @guide_form.errors.full_messages
      render failure_template
    end
  end

  def guide_form_params
    params.fetch(:guide, {})
  end
end
