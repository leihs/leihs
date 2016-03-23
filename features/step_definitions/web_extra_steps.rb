When 'I reload the page' do
  visit URI.parse(current_url).path
end

When 'I scroll to the bottom of the page' do
  page.execute_script 'window.scrollBy(0,10000)'
end

When 'I fetch all pages of the list' do
  if has_selector? '#inventory > .line'
    within '#inventory' do
      all('.page[data-page]').each do |data_page|
        page.driver.browser.action.move_to(data_page.native).perform
        expect(data_page).to have_selector '.line'
        expect(data_page).to have_selector '.line div'
      end
    end
  end
end

When /^I follow the sloppy link "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    
    # Capybara has no regex matching on click_link, and we 
    # have quite sloppy links containing images, numbers, elks
    # and bananas between the <a> tags. This can match them all.
    # Well, maybe not the elks.
    find('a', text: /.*#{text}.*/i).click 
true
  end
end

When /^I follow the sloppy link "([^"]*)" in the greybox$/ do |text|
  # Wait for the frame to finish appearing
  expect(has_selector?('#GB_frame', visible: true)).to be true

  within_frame 'GB_frame' do
    step "I follow the sloppy link \"#{text}\""
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

# using this step with 'within' has not been tested yet!
Then /^"([^"]*)" should appear before "([^"]*)"(?: within "([^"]*)")?$/ do
|first, second, selector|
  step 'I wait for the spinner to disappear'
  with_scope(selector) do
    page.body.index(first).should < page.body.index(second)
  end
end

When 'I wait for the spinner to disappear' do
  # capybara black magic - wait for div to become invisible
  expect(has_xpath?( "//div[@id='loading_panel']", visible: false)).to be true
end
