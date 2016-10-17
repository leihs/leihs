# -*- encoding : utf-8 -*-

When(/^I try to perform an action in the manage area without being logged in$/) do
  step 'I am doing a hand over'
  page.execute_script %Q{ $.ajax({url: "/logout"}); }
  find('#assign-or-add-input input').set 'A B'
  find('#assign-or-add-input input')
end

Then(/^I am redirected to the start page$/) do
  find('#flash')
  expect(current_path).to eq root_path
end

Then(/^I am notified that I am not logged in$/) do
  expect(has_content?(_('You are not logged in.'))).to be true
end
