When /^I dump the response$/ do
  puts body
end

When /^I dump the response to '([^']*)'$/ do |filename|
  File.open(filename, File::CREAT|File::TRUNC|File::RDWR) do |f|
    f.puts body
  end
end

When /^I start the debugger$/ do
  debugger
end

