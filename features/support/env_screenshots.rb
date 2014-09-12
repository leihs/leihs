def take_screenshot
  @screenshot_dir ||= Rails.root.join("tmp","capybara")
  Dir.mkdir @screenshot_dir rescue nil
  path= @screenshot_dir.join("screenshot_#{Time.zone.now.iso8601.gsub(/:/,'-')}.png")
  case Capybara.current_driver
  when :selenium_firefox, :selenium_chrome
    page.driver.browser.save_screenshot(path) rescue nil
  when :selenium_phantomjs
    page.driver.render(path, :full => true) rescue nil
  else
    Rails.logger.warn "Taking screenshots is not implemented for #{Capybara.current_driver}."
  end
end

After do |scenario|
  take_screenshot if scenario.failed?
end

AfterStep do |scenario| 
  if t = scenario.instance_eval{@tags}
    if t.tags.map(&:name).include? "@take_screenshots" 
      take_screenshot
    end
  end
end
