module CapybaraHelpers
  def click_first_button(value)
    click_button value, match: :first
  end

  def click_first_link(value)
    click_link value, match: :first
  end

  def within_guide_index_row(title, &block)
    within(:xpath, %{//a[.="#{title}"]/ancestor::tr}, &block)
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature
end
