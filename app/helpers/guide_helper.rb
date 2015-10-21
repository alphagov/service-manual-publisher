module GuideHelper
  def edit_action_label(guide)
    if guide.work_in_progress_edition?
      'Continue editing'
    else
      'Create new edition'
    end
  end
end
