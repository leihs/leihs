Given /^pending$/ do
  pending
end

Given "pending - reported by $who on $date" do |who, date|
  pending
end

Given "resolved by $who on $date" do |who, date|
  # do nothing
end

Given /^reported by (.*) on (.*)/ do |who, date|
  # do nothing
end

Given /pending - (?!reported by)(.*)/ do |explanation|
  pending
end

Given "test pending" do
  pending
end

# This step is not active currently, since it is used in a @wip feature.
# It needs to be eventually migrated from culerity to capybara all the same 
When /I fill in (\w+) of "([^\"]*)" with "([^\"]*)"/ do |order, field, value|
  text_fields = $browser.text_fields
  matching = text_fields.find_all { |t| t.id.match( field ) }
  matching[order.to_i].set(value)
end

# Date changing hackery
When "I beam into the future to $date" do |date|
  back_to_the_future( Factory.parsedate( date ) )
end

When "I beam back into the present" do
  back_to_the_present
end
