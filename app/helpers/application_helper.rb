module ApplicationHelper
  def alert_css_class(flash_type)
    {
      notice: 'alert-success',
      alert: 'alert-warning',
      error: 'alert-danger'
    }[flash_type.to_sym]
  end
end
