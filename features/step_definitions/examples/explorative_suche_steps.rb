# -*- encoding : utf-8 -*-

Given(/^I open the category filter$/) do
  find('#categories-toggle').click
  find('#categories #category-list')
end

When(/^I select a category$/) do
  c = find("#categories #category-list a[data-type='category-filter']", match: :first)
  c_id = c[:"data-id"]
  @category = Category.find c_id
  expect(c.text).to eq @category.name

  c.click

  find("#categories #category-current a[data-type='category-current'][data-id='#{c_id}']", text: @category.name)
end

Then(/^I see that category's children$/) do
  @category.children.each do |child|
    find('#categories', match: :prefer_exact, text: child.name)
  end
end

Then(/^I can select the child category$/) do
  @child_category = Category.find find("a[data-type='category-filter']", match: :first)[:"data-id"]
  expect(@category.children).to include @child_category

  find("a[data-type='category-filter']", match: :first).click

  find('#category-current', text: @child_category.name)
end

Then(/^I see the top-level category as well as the currently selected one and its children$/) do
  find('#category-root', text: @category.name)
  find('#category-current', text: @child_category.name)
end

Then(/^the inventory I see is filtered by this category$/) do
  within('#inventory') do
    all(".line[data-type='model']", minimum: 1).each do |model_line|
      model = Model.find_by_name(model_line.find('.col2of5 strong').text)
      expect((model.categories.include?(@child_category) or @child_category.descendants.any? {|c| model.categories.include? c})).to be true
    end
  end
end

Then(/^I can navigate back to the current top-level category in one single step$/) do
  find('#category-root a').click
  step 'I see that category\'s children'
end

Then(/^I can navigate back to the list of top-level categories in one single step$/) do
  step 'I can navigate to the parent category'
  Category.roots.each do |child|
    find("#categories #category-list [data-type='category-filter']", match: :prefer_exact, text: child.name)
  end
end

When(/^I collapse the category filter$/) do
  find('#categories-toggle').click
end

Then(/^I see only the list of inventory$/) do
  expect(has_no_selector?('#categories #category-list', visible: true)).to be true
end

When(/^I search for a category name$/) do
  @category = Category.first
  @search_term = @category.name[0..-2]
  find('#category-search').set @search_term
  find('#category-root', text: @search_term)
  find('.line', match: :first)
end

Then(/^all categories whose names match the search term are shown$/) do
  within '#categories #category-list' do
    Category.all.map(&:name).reject{|name| not name[@search_term]}.each do |name|
      find("[data-type='category-filter']", match: :prefer_exact, text: name)
    end
    expect(all("[data-type='category-filter']").size).to eq all("[data-type='category-filter']", text: @search_term).size
  end
end

Then(/^I see a search indicator with the current search term as well the currently selected category and its children$/) do
  find('#category-root .fa.fa-search')
  find('#category-root', text: @search_term)
  find('#category-current', text: @child_category.name)
  @child_category.children.each do |child|
    find('#category-list', text: child.name)
  end
end

Given(/^I used the explorative search to get to a subcategory$/) do
  step 'I open the inventory'
  step 'I open the category filter'
  step 'I select a category'
end

Then(/^I can navigate to the parent category$/) do
  find('#category-current a').click
end


# Dann(/^kann ich ein Modell anhand der explorativen Suche wählen$/) do
#   find("button.addon[type='submit'] .fa.fa-plus").click
#   find(".modal.ui-shown .line", match: :first)
#   find("[data-type='category-filter']", :match => :first).click
#   find(".modal.ui-shown .line", match: :first)
#   model = Model.find find(".modal.ui-shown .line", match: :first)["data-id"]
#   find(".modal.ui-shown .line .button", match: :first).click
#   find("#flash")
#   if @contract
#     expect(@contract.models.include? model).to be true
#   else
#     expect(@customer.reservations_bundles.map(&:models).flatten.include? model).to be true
#   end
# end

Then(/^the explorative search shows only models from my inventory pool$/) do
  find("button.addon[type='submit'] .fa.fa-plus").click
  find('.modal.ui-shown .line', match: :first)
  all('.modal .line[data-id]').each do |line|
    model = Model.find line['data-id']
    expect(@current_inventory_pool.models.include? model).to be true
  end
end

When(/^I select the not categorized filter$/) do
  within('#categories #category-list') do
    find("a[data-type='category-filter']", text: '* %s *' % _('Not categorized')).click
  end
end

Then(/^I see the models not assigned to any category$/) do
  step 'I fetch all pages of the list'
  within('#inventory') do
    @current_inventory_pool.models.select {|model| model.categories.empty? }.each do |model|
      find(".line[data-id='#{model.id}']", match: :prefer_exact, text: model.name)
    end
  end
end
