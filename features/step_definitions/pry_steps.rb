# rubocop:disable Lint/Debugger
When /^I pry/ do
  binding.pry
end 

When /^I use pry$/ do
  binding.pry
end
# rubocop:enable Lint/Debugger
