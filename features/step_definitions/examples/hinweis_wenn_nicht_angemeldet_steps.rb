# -*- encoding : utf-8 -*-

# Wenn /^versuche eine Aktion im Backend auszuführen obwohl ich abgemeldet bin$/ do
When(/^I try to perform an action in the manage area without being logged in$/) do
  step 'I am doing a hand over'
  page.execute_script %Q{ $.ajax({url: "/logout"}); }
  find('[data-add-contract-line]').set 'A B'
  find('[data-add-contract-line]')
end

# Dann /^werden ich auf die Startseite weitergeleitet$/ do
Then(/^I am redirected to the start page$/) do
  find('#flash')
  expect(current_path).to eq root_path
end

# Dann /^sehe einen Hinweis, dass ich nicht angemeldet bin$/ do
Then(/^I am notified that I am not logged in$/) do
  expect(has_content?(_('You are not logged in.'))).to be true
end
