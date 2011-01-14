When "I reload the page" do
  visit URI.parse(current_url).path
end


When /^I follow the sloppy link "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    
    # Capybara has no regex matching on click_link, and we 
    # have quite sloppy links containing images, numbers, elks
    # and bananas between the <a> tags. This can match them all.
    # Well, maybe not the elks.
    find('a', :text => /.*#{text}.*/i).click 
  end
end

When /^I follow the sloppy link "([^"]*)" in the greybox$/ do |text|
  # Wait for the frame to finish appearing
  page.has_css?("#GB_frame", :visible => true)

  within_frame "GB_frame" do
    When "I follow the sloppy link \"#{text}\""
  end
end
