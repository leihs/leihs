require 'selenium/webdriver'

browser_to_use = :firefox

Capybara.register_driver :selenium do |app|
  case browser_to_use
    when :firefox
      profile = Selenium::WebDriver::Firefox::Profile.new
      # we need a firefox extension to start intercepting javascript errors before the page
      # scripts load
      # see https://github.com/mguillem/JSErrorCollector
      profile.add_extension File.join(Rails.root, "features/support/extensions/JSErrorCollector.xpi")
      Capybara::Selenium::Driver.new app, :profile => profile
    when :chrome
      Capybara::Selenium::Driver.new app, browser: :chrome
    end
end

if browser_to_use == :firefox
  After do |scenario|
    if page.driver.to_s.match("Selenium") #and selenium_browser == :firefox
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
end
