module CapybaraHelpers
  def click_first_button(value)
    first(:css, "input[value='#{value}']").click
  end
end


RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature
end
