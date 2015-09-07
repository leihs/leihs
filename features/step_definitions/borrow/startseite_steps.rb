# -*- encoding : utf-8 -*-

Given(/^I am listing the main categories$/) do
  visit borrow_root_path
end

Then(/^I see exactly those main categories that are useful for my user$/) do
  @main_categories = @current_user.all_categories.select {|c| c.parents.empty?}
  categories_counter = 0
  @main_categories.each do |mc|
    find('a', match: :first, text: mc.name)
    categories_counter += 1
  end
  expect(categories_counter).to eq @main_categories.count
end

When(/^I enter to a main category$/) do
  @main_category = (@current_user.all_categories & Category.roots).sample
  find("[data-category_id='#{@main_category.id}'] a", match: :first).click
end

When(/^I hover over a main category with children$/) do
  @main_category = (@current_user.all_categories & Category.roots).find do |c|
    borrowable_children = (@current_user.categories.with_borrowable_items & c.children)
    c.children.size != borrowable_children.size and borrowable_children.size > 0
  end
  within('[data-category_id]', text: @main_category.name) do
    find('.dropdown-holder').hover
  end
end

Then(/^I see only this main category's children that are useful and available to me$/) do
  second_level_categories = @main_category.children
  visible_2nd_level_categories = (@current_user.categories.with_borrowable_items & @main_category.children)
  @second_level_category = visible_2nd_level_categories.first
  find('a', match: :first, text: @second_level_category.name)

  visible_2nd_level_categories_count = 0
  within find('[data-category_id] .padding-inset-s', match: :first, text: @main_category.name).first(:xpath, '../..').find('.dropdown-holder', match: :first) do
    visible_2nd_level_categories.each do |c|
      find('.dropdown a', match: :first, text: c.name)
      visible_2nd_level_categories_count += 1
    end
  end
  expect(visible_2nd_level_categories_count).to eq visible_2nd_level_categories.size
end

When(/^I choose one of these child categories$/) do
  click_link @second_level_category.name
end

Then(/^I see the model list for this main category$/) do
  expect((Rack::Utils.parse_nested_query URI.parse(current_url).query)['category_id'].to_i).to eq @main_category.id
end

Then(/^I see the model list for this category$/) do
  expect((Rack::Utils.parse_nested_query URI.parse(current_url).query)['category_id'].to_i).to eq @second_level_category.id
end

Given(/^there is a main category whose child categories cannot offer me any items$/) do
  @main_category = (@current_user.all_categories & Category.roots).find do |c|
    (@current_user.categories.with_borrowable_items & c.children).size == 0
  end
end

Then(/^that main category has no child category dropdown$/) do
  expect(find('.row.emboss.focus-hover', match: :first, text: @main_category.name).has_no_selector? '.dropdown-holder').to be true
end

Then(/^I see for each category its image, or if not set, the first image of a model from this category$/) do
  @main_categories.each do |mc|
    img_el = find('a', match: :first, text: mc.name).find('img')
    response = get img_el[:src]
    if image = mc.image
      expect(response.location).to match /#{image.public_filename}/
    end
  end
end

Given(/^there exists a main category with own image$/) do
  (@current_user.all_categories & Category.roots).find do |c|
    expect(c.images.exists?).not_to be_nil
  end
end

Given(/^there exists a main category without own image but with a model with image$/) do
  expect((@current_user.all_categories & Category.roots).find do |c|
    not c.images.exists? and c.all_models.detect{|m| not m.image.blank? }
  end).not_to be_nil
end
