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

  def fill_in_final_url(with)
    page.find_field("Final URL").base.native.remove_attribute("readonly")
    fill_in "Final URL", with: with
  end

  def within_guide_history_edition(number, &block)
    within(:xpath, "//div
                        [contains(@class, 'panel')]
                        [div
                          [contains(@class, 'panel-heading')]
                          [contains(., 'Edition ##{number}')]
                        ]", &block)
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature
end
