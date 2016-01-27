module CapybaraHelpers
  def click_first_button(value)
    click_button value, match: :first
  end

  def within_guide_index_row(name, &block)
    within(:xpath, %{//a[.="#{name}"]/ancestor::tr}, &block)
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature
end
