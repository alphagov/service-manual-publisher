module CapybaraHelpers
  def click_first_button(value)
    click_button value, match: :first
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature
end
