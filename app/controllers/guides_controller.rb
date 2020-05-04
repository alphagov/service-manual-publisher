class GuidesController < ApplicationController
  def index
    scope = Guide.all
    @guides = GuidesFilter.new(scope).by(params)
  end

  def new
    type = params[:type].presence_in(%w[GuideCommunity Point])
    guide = Guide.new(type: type)

    @guide_form = GuideForm.build(
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

    @guide_form = GuideForm.build(
      guide: guide,
      edition: guide.latest_edition,
      user: current_user,
    )
  end

  def update
    guide = Guide.find(params[:id])

    if params[:send_for_review].present?
      manage(guide, :request_review!, message: "A review has been requested")
    elsif params[:approve_for_publication].present?
      manage(guide, :approve_for_publication!, message: "Thanks for approving this guide")
    elsif params[:publish].present?
      manage(guide, :publish, message: "Guide has been published")
    elsif params[:discard].present?
      manage(guide, :discard_draft, message: "Draft has been discarded", redirect: root_path)
    else
      save(guide)
    end
  end

  def unpublish
    @guide = Guide.find(params[:id])
    @redirect = Redirect.new(old_path: @guide.slug)
  end

  def confirm_unpublish
    @guide = Guide.find(params[:id])
    @redirect = Redirect.new(old_path: @guide.slug)

    destination = params.fetch(:redirect).fetch(:new_path)

    guide_manager = GuideManager.new(guide: @guide, user: current_user)
    result = guide_manager.unpublish_with_redirect(destination)

    if result.success?
      redirect_to edit_guide_path(@guide), notice: "Guide has been unpublished"
    else
      @errors = result.errors
      render "unpublish"
    end
  end

private

  def manage(guide, action, opts = {})
    redirect = opts.fetch(:redirect, edit_guide_path(guide))
    message = opts.fetch(:message, nil)

    @guide_form = GuideForm.build(
      guide: guide,
      edition: guide.latest_edition,
      user: current_user,
    )

    if guide_has_changed_since_editing?(guide)
      flash.now[:error] = guide_has_changed_message
      render "edit"
      return
    end

    guide_manager = GuideManager.new(guide: guide, user: current_user)
    result = guide_manager.public_send(action)

    if result.success?
      redirect_to redirect, notice: message
    else
      flash.now[:error] = result.errors
      render "edit"
    end
  end

  def save(guide)
    failure_template = guide.persisted? ? "edit" : "new"

    @guide_form = GuideForm.build(
      guide: guide,
      edition: guide.editions.build(created_by: current_user),
      user: current_user,
    )
    @guide_form.assign_attributes(guide_form_params)

    if guide_has_changed_since_editing?(guide)
      flash.now[:error] = guide_has_changed_message
      render "edit"
    elsif @guide_form.save
      redirect_to edit_guide_path(@guide_form), notice: "Guide has been saved"
    else
      render failure_template
    end
  end

  def guide_form_params
    params.fetch(:guide, {})
  end

  def guide_has_changed_since_editing?(guide)
    edition = guide.latest_edition

    if edition.present?
      edition.fingerprint != guide_form_params[:fingerprint_when_started_editing]
    else
      false
    end
  end

  def guide_has_changed_message
    "There have been changes since you started editing. Your changes haven't been saved " \
    "but are still visible in the form below."
  end
end
