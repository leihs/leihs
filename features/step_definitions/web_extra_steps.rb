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
true
  end
end

When /^I follow the sloppy link "([^"]*)" in the greybox$/ do |text|
  # Wait for the frame to finish appearing
  page.has_css?("#GB_frame", :visible => true)

  within_frame "GB_frame" do
    When "I follow the sloppy link \"#{text}\""
  end
end

When /^I click "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    begin
      click_link text
    rescue ElementNotFound
      click_button(text)
    end
  end
end

# using this step with 'within' is not tested!
Then /^"([^"]*)" should appear before "([^"]*)"(?: within "([^"]*)")?$/ do
|first, second, selector|
  with_scope(selector) do
    page.body.index(first).should < page.body.index(second)
  end
end

