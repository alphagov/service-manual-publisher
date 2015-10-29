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

  def table_row_class_for(guide)
    row_classes = {
      "draft"            => "danger",
      "review_requested" => "warning",
      "approved"         => "success",
      "published"        => "info",
    }
    row_classes[guide.latest_edition.state]
  end
end
