When /^I pick the model "([^"]*)" from the list$/ do |model_name|
  find('tr', match: :first, text: /#{model_name}/).find_link('Show').click
end

When /^I check the category "([^"]*)"$/ do |category|   
  within 'ul.simple_tree' do
    all('li').each do |item|
      if item.text == category and item.find('input', match: :first).native.attribute('checked').nil?
        item.find('input', match: :first).click
      end
    end
  end
end

When /^I uncheck the category "([^"]*)"$/ do |category|
  within 'ul.simple_tree' do
    all('li').each do |item|
      if item.text == category and !item.find('input', match: :first).native.attribute('checked').nil?
        item.find('input', match: :first).click
      end
    end
  end
end

Then /^the model "([^"]*)" should( not)? be in category "([^"]*)"$/ do |model_name, boolean, category_name|
  step "I follow the sloppy link \"All Models\""
  category_list = find('tr', match: :first, text: model_name).all('ul')[3]
  case boolean
    when ' not'
      expect(category_list.text).not_to match /#{category_name}/
    else
      expect(category_list.text).to match /#{category_name}/
  end
end

Given(/^there is a main category$/) do
  @main_category = Category.roots.order('RAND()').first
end

Then(/^this category can have children$/) do
  child_category = Category.where.not(id: @main_category).order('RAND()').detect {|c| not @main_category.children.include? c }
  @main_category.children << child_category
  expect(@main_category.reload.children.include? child_category).to be true
end

Then(/^this category has no parents$/) do
  expect(@main_category.parents).to be_empty
end

# We wrap some steps in this so that it's guaranteed that we get a logout. This is
# necessary so any "I log in as...." steps in the Background section actually work, as
# they don't work when a user is already logged in. This prevents failing steps from
# breaking following tests.
After('@logoutafter') do
  step "I follow the sloppy link \"Logout\""
end