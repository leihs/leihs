When(/^I visit "(.*)"$/) do |path|
  visit path
end

Then(/^all is correct$/) do
  expect(has_content? _("All correct")).to be true
  expect(has_selector?(".icon-check-sign")).to be true
end

