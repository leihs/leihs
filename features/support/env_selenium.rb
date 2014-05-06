require 'selenium/webdriver'

##################################################################################

Capybara.register_driver :selenium_phantomjs do |app|
  Capybara::Selenium::Driver.new app, browser: :phantomjs #, capabilities: {a: 1}
end

Capybara.register_driver :selenium_firefox do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  # we need a firefox extension to start intercepting javascript errors before the page scripts load
  # see https://github.com/mguillem/JSErrorCollector
  profile.add_extension File.join(Rails.root, "features/support/extensions/JSErrorCollector.xpi")
  Capybara::Selenium::Driver.new app, :profile => profile
end

##################################################################################

Before('@javascript', '~@firefox') do
  Capybara.current_driver = :selenium_phantomjs
  Capybara::Screenshot.autosave_on_failure = false # FIXME capybara-screenshot could not detect a screenshot driver for 'selenium_phantomjs'. Saving with default with unknown results.
end

Before('@javascript', '@firefox') do
  Capybara.current_driver = :selenium_firefox
  Capybara::Screenshot.autosave_on_failure = false # FIXME capybara-screenshot could not detect a screenshot driver for 'selenium_firefox'. Saving with default with unknown results.
  page.driver.browser.manage.window.maximize # to prevent Selenium::WebDriver::Error::MoveTargetOutOfBoundsError: Element cannot be scrolled into view
end

Before do
  Cucumber.logger.info "Current capybara driver: %s\n" % Capybara.current_driver
end

After('@javascript', '@firefox') do |scenario|
  if page.driver.to_s.match("Selenium")
    errors = page.execute_script("return window.JSErrorCollector_errors.pump()")

    if errors.any?
      puts '-------------------------------------------------------------'
      puts "Found #{errors.length} javascript errors"
      puts '-------------------------------------------------------------'
      errors.each do |error|
        puts "    #{error["errorMessage"]} (#{error["sourceName"]}:#{error["lineNumber"]})"
      end
      # Raise an error here if you want JS errors to make your Capybara test count as failed
      #raise "Javascript errors detected, see above"
    end

  end
end
