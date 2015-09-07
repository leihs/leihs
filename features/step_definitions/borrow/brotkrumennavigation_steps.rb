# -*- encoding : utf-8 -*-

Then(/^I see the breadcrumb navigation bar$/) do
  expect(has_selector?('nav .navigation-tab-item', text: _('Start'))).to be true
end

Then(/^the first position in the breadcrumb navigation bar is always the home button$/) do
  @home_button = all('nav .navigation-tab-item').first
  expect(@home_button.text).to match _('Start')
end

Then(/^that button directs me to the main categories$/) do
  @home_button.click
  expect(current_path).to eq borrow_root_path
end

When(/^I pick a first-level category from the results of the explorative search$/) do
  category_link = find('#explorative-search h2 a', match: :first)
  @category = Category.find_by_name category_link[:title]
  category_link.click
end

When(/^I choose a subcategory$/) do
  within('[data-category_id]', match: :first) do
    find('.dropdown-holder').hover
  end
  @category_el = find('a.dropdown-item', match: :first)
  @category_name = @category_el.text
  @category = Category.find_by_name @category_name
  @category_el.click
end

Then(/^that category opens$/) do
  expect((Rack::Utils.parse_nested_query URI.parse(current_url).query)['category_id'].to_i).to eq @category.id
end

When(/^I pick a second-level category from the results of the explorative search$/) do
  category_link = find('#explorative-search h3 a', match: :first)
  @category = Category.find_by_name category_link[:title]
  category_link.click
end

When(/^I choose a main category$/) do
  category_el = find('.row.emboss.focus-hover', match: :first)
  @category = Category.find_by_name category_el.find('h2', match: :first).text
  category_el.find('a', match: :first).click
end

Then(/^that category is the second and last element of the breadcrumb navigation bar$/) do
  tabs = all('nav .navigation-tab-item')
  expect(tabs[1].text[@category.name]).to be
  expect(tabs.length).to eq 2
end

When(/^I open a model$/) do
  find('.line[data-id]', match: :first).click
end

Then(/^I see the whole path I traversed to get to the model$/) do
  #step 'die Kategorie ist das zweite und letzte Element der Brotkrumennavigation'
  step 'that category is the second and last element of the breadcrumb navigation bar'
end

Then(/^none of the elements of the breadcrumb navigation bar are active$/) do
  expect(has_no_selector?('nav .navigation-tab-item.active')).to be true
end
