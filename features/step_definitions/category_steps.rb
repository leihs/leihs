When /^I pick the model "([^"]*)" from the list$/ do |model_name|
  find("tr", :text => /#{model_name}/).find_link("Show").click
end

When /^I check the category "([^"]*)"$/ do |category|
  #debugger
  
  #lists = all(:xpath, "//ul[@class='simple_tree']")
  
  # Because there can be multiple ul.simple_trees on one page and we don't have any IDs
  # to differentiate between them, we must iterate on all checkboxes of each tree and
  # select only those which we haven't selected yet in the previous iteration (!).
#   lists = all("ul.simple_tree")
#   lists.each do |list|
#     list.all("li").each do |item|
#       
#       #debugger
#       if item.text == category and item.find("input").native.attribute("checked").nil?
#         #debugger
#         item.find("input").click
#       end
#     end
#   end
#   
  list_items = all("ul.simple_tree li")
  list_items.each do |item|
      if item.text == category and item.find("input").native.attribute("checked").nil?
        #debugger
        item.find("input").click
      end
  end
  
  
  
  
end

Then /^the model "([^"]*)" should be in category "([^"]*)"$/ do |model_name, category_name|
  When "I follow the sloppy link \"All Models\""
  category_list = find("tr", :text => "#{model_name}").all("ul")[3]
  category_list.text.should =~ /#{category_name}/
end

# We wrap some steps in this so that it's guaranteed that we get a logout. This is
# necessary so any "I log in as...." steps in the Background section actually work, as
# they don't work when a user is already logged in. This prevents failing steps from
# breaking following tests.
After('@logoutafter') do
  And "I follow the sloppy link \"Logout\""
end