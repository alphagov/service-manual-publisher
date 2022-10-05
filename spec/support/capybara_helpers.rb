module CapybaraHelpers
  def click_first_button(value)
    click_button value, match: :first
  end

  def click_first_link(value)
    click_link value, match: :first
  end

  def within_guide_index_row(title, &block)
    within(:xpath, %(//a[.="#{title}"]/ancestor::tr), &block)
  end

  def within_topic_section(title, &block)
    within(:xpath, %{//li[contains(@class, "list-group-item")][.//input[@value="#{title}"]]}, &block)
  end

  def fill_in_final_url(with)
    page.find_field("Final URL").base.native.remove_attribute("readonly")
    fill_in "Final URL", with:
  end

  ##
  # Based on Capybara's fill_in method, but using all().last instead of find
  def fill_in_last(locator, options = {})
    if locator.is_a? Hash
      options = locator
      locator = nil
    end

    unless options.is_a?(Hash) && options.key?(:with)
      raise "Must pass a hash containing 'with'"
    end

    with = options.delete(:with)
    fill_options = options.delete(:fill_options)
    all(:fillable_field, locator, options).last.set(with, fill_options)
  end

  def within_guide_history_edition(number, &block)
    within(
      :xpath,
      "//div
                        [contains(@class, 'panel')]
                        [div
                          [contains(@class, 'panel-heading')]
                          [contains(., 'Edition ##{number}')]
                        ]",
      &block
    )
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature
end
