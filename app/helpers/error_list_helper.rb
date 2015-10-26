module ErrorListHelper; end

class ActionView::Helpers::FormBuilder
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::AssetTagHelper

  def error_list(field)
    return nil if object.errors.messages[field].nil?

    content_tag :ul do
      object.errors.messages[field].map do |error|
        content_tag :li, class: "text-danger" do
          error
        end
      end.join("").html_safe
    end
  end
end
