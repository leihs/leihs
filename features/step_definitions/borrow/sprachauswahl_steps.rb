# -*- encoding : utf-8 -*-

#Angenommen(/^ich sehe die Sprachauswahl$/) do
Given(/^I see the language list$/) do
  find("footer a[href*='locale']", match: :first)
end

#Wenn(/^ich die Sprache auf "(.*?)" umschalte$/) do |language|
When(/^I change the language to "(.*?)"$/) do |language|
  find("footer a", text: language).click
end

Then(/^the language is "(.*?)"$/) do |language|
  expect(@current_user.reload.language.name).to eq language
  find("footer a[href=''] strong", text: language)
end
