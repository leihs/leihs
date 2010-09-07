# Here are steps in case we ever get a 'General' group

#Then /^no items of that Model should be (\w*) in any group$/ do |state|
#  Then "0 items of that Model should be available in Group 'General' only"
#end


#Given /^(\d+) items of that Model in Group "([^"]*)"$/ do |n, group_name|
#  Given "#{n} items of model '#{@model.name}' exist"
#  When "I move #{n} items of that Model from Group \"General\" to Group \"#{group_name}\""
#end
