Then /^dump the response$/ do
  puts body
end

Then /^dump the response to '([^']*)'$/ do |filename|
  File.open(filename, File::CREAT|File::TRUNC|File::RDWR) do |f|
    f.puts body
  end
end


# rubocop:disable Lint/Debugger
Then 'start the debugger' do
  debugger
  true
end
# rubocop:enable Lint/Debugger

Then 'reindex' do
  puts `rake ts:reindex`
end

# this is for commenting or explaining inside Scenarios
Given /^comment:/ do
  true
end

############################################################
# Tools to slow down execution, to help following and debugging
# tests

# Then wait
#
Then /^wait$/ do
  @delay ||= 2 # default
  step "wait #{@delay} seconds"
end

Then /^wait (\d+) second(s?)/ do |seconds, plural|
  sleep seconds.to_i
end

# tag your scenarion with '@slowly' and then every step
# will be executed with a default delay of 2 seconds
Before('@slowly') do
  step 'wait' unless @skip_wait
end

AfterStep('@slowly') do
  step 'wait' unless @skip_wait
end

# since only Scenarios and not single steps can be tagged with
# '@slowly', you can switch on and off delaying between steps
#
# When I switch on waiting
# When I switch off waiting
#
Then 'switch $waitstate waiting' do |waitstate|
  @skip_wait = (waitstate == 'off')
end

Then 'set the default delay to $delay' do |delay|
  @delay = delay.to_i
end

