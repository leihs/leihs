Given /^pending$/ do
  pending
end

When /we wait (\d+) second(s?)/ do |seconds, plural|
  sleep seconds.to_i
end


