# encoding: utf-8

#Wenn(/^ich im Verwalten\-Bereich bin$/) do
When(/^I am in the manage section$/) do
  visit manage_root_path
end

#Dann(/^habe ich die Möglichkeit zur Statistik\-Ansicht zu wechseln$/) do
Then(/^I can choose to switch to the statistics section$/) do
  find("a[href='#{admin_statistics_path}']", match: :first)
end
