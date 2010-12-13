
When /^I follow the sloppy link "([^"]*)"$/ do |text|
  # Capybara has no regex matching on click_link, and we 
  # have quite sloppy links containing images, numbers, elks
  # and bananas between the <a> tags. This can match them all.
  # Well, maybe not the elks.
  find('a', :text => /.*#{text}.*/i).click 
end