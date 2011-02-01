When /^I dump the response$/ do
  puts body
end

When /^I dump the response to '([^']*)'$/ do |filename|
  File.open(filename, File::CREAT|File::TRUNC|File::RDWR) do |f|
    f.puts body
  end
end

When /^I look at the page$/ do
  save_and_open_page
end

When /^I start the debugger$/ do
  debugger
  true
end

When "I reindex" do
  `rake ts:index`
end

# this is for commenting or explaining inside Scenarios
Given /^comment:/ do
  true
end

############################################################
# Tools to slow down execution, to help following and debugging
# tests

# When I wait
#
When /^(\w+) wait(s?)$/ do |who, plural|
  @delay ||= 2 # default
  When "#{who} wait#{plural} #{@delay} seconds"
end

When /(\w+) wait (\d+) second(s?)/ do |who, seconds, plural|
  sleep seconds.to_i
end

# tag your scenarion with '@slowly' and then every step
# will be executed with a default delay of 2 seconds
Before('@slowly') do
  When "I wait" unless @skip_wait
end

AfterStep('@slowly') do
  When "I wait" unless @skip_wait
end

# since only Scenarios and not single steps can be tagged with
# '@slowly', you can switch on and off delaying between steps
#
# When I switch on waiting
# When I switch off waiting
#
When "I switch $waitstate waiting" do |waitstate|
  @skip_wait = (waitstate == "off")
end

When "I set the default delay to $delay" do |delay|
  @delay = delay.to_i
end

