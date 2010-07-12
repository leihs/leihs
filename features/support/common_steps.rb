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


