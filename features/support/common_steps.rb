Given /^pending$/ do
  pending
end

Given "pending - reported by $who on $date" do |who, date|
  pending
end

Given /pending - (?!reported by)(.*)/ do |explanation|
  pending
end

When /(\w+) wait (\d+) second(s?)/ do |who, seconds, plural|
  sleep seconds.to_i
end

When "I switch off JavaScript because $reason" do |reason|
  # see https://sourceforge.net/tracker/index.php?func=detail&aid=2969230&group_id=47038&atid=448266
  $browser.javascript_enabled=false
end

Then "I want to see the current page content for debugging" do
  puts $browser.html
end

When /I follow "([^\"]*)" inside '([^\"]*)'/ do |link, element_id|
  container = $browser.div(:id => element_id)
  container.exists?.should be_true
  link = container.link(:text => link)
  link.exists?.should be_true
  link.click
end

When /I fill in (\w+) of "([^\"]*)" with "([^\"]*)"/ do |order, field, value|
  text_fields = $browser.text_fields
  matching = text_fields.find_all { |t| t.id.match( field ) }
  matching[order.to_i].set(value)
end

