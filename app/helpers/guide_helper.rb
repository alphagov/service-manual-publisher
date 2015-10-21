module GuideHelper
  def edit_action_label(guide)
    if guide.work_in_progress_edition?
      'Continue editing'
    else
      'Create new edition'
    end
  end

  def latest_editor_name(guide)
    guide.latest_edition.user.try(:name).to_s
  end
end
