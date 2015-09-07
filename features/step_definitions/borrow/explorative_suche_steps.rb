# -*- encoding : utf-8 -*-

Then(/^I see the explorative search$/) do
  find '#explorative-search'
end

Then(/^it contains the currently selected category's direct children and their children$/) do
  @children = @category.children.reject {|c| Model.from_category_and_all_its_descendants(@category).active.blank?}
  @grand_children = @children.map(&:children).flatten.reject {|c| Model.from_category_and_all_its_descendants(c).active.blank?}

  within '#explorative-search' do
    @children.map(&:name).each {|c_name| find('a', match: :first, text: c_name)} unless @children.blank?
    @grand_children.map(&:name).each {|c_name| find('a', match: :first, text: c_name)} unless @grand_children.blank?
  end
end

Then(/^those categories and their children that do not contain any borrowable items are hidden$/) do
  expect((@children + @grand_children).length).to eq find('#explorative-search', match: :first).all('a').length
end

When(/^I choose a category$/) do
  @category = @category.children.reject {|c| Model.from_category_and_all_its_descendants(@category).active.blank?}.first
  find('#explorative-search', match: :first).find('a', match: :first, text: @category.name).click
end

Then(/^the models of the currently chosen category are shown$/) do
  expect((Rack::Utils.parse_nested_query URI.parse(current_url).query)['category_id'].to_i).to eq @category.id
  find('#model-list', match: :first)
  models = Model.from_category_and_all_its_descendants(@category).active
  within '#model-list' do
    models.each do |model|
      find('.line', match: :first, text: model.name)
    end
  end
end

Given(/^I am in the model list viewing a category without children$/) do
  @category = Category.find {|c| c.descendants.blank?}
  visit borrow_models_path category_id: @category.id
end

Then(/^the explorative search panel is not visible and the model list is expanded$/) do
  expect(has_selector?('.col1of1 #model-list')).to be true
end
