# -*- encoding : utf-8 -*-

Given(/^I am listing a category of models of which at least one is borrowable by me$/) do
  @model = @current_user.models.borrowable.detect do |m|
    m.images.size > 1 and
    not m.description.blank? and
    not m.attachments.blank? and
    m.properties.length > 5 and
    not m.compatibles.blank?
  end
  category = @model.categories.first
  visit borrow_models_path(category_id: category.id)
end

When(/^I pick one model from the list$/) do
  find(".line[data-id='#{@model.id}']", match: :first).click
end

Then(/^I see that model's detail page$/) do
  expect(current_path).to eq borrow_model_path(@model)
end

Then(/^I see the following model information:$/) do |table|
  table.raw.flatten.each do |section|
    case section
      when 'Model name' 
        expect(has_content?(@model.name)).to be true
      when 'Manufacturer'
        expect(has_content?(@model.manufacturer)).to be true
      when 'Images'
        @model.images.each_with_index {|image,i| find("img[src='#{model_image_thumb_path(@model, offset: i)}']", match: :first)}
      when 'Description'
        expect(has_content?(@model.description)).to be true
      when 'Attachments'
        @model.attachments.each {|a| find("a[href='#{a.public_filename}']", match: :first)}
      when 'Properties'
        @model.properties.each do |p|
          expect(has_content?(p.key)).to be true
          expect(has_content?(p.value)).to be true
        end
      when 'Compatible models'
        @model.compatibles.each do |c|
          find("a[href='#{borrow_model_path(c)}']", match: :first)
          find("img[src='#{model_image_thumb_path(c)}']", match: :first)
          expect(has_content?(c.name)).to be true
        end
      else
        rais 'unknown section'
    end
  end
end

Given(/^I see a model's detail page that includes images of the model$/) do
  @model = @current_user.models.borrowable.detect {|m| m.images.size > 1}
  visit borrow_model_path @model
end

When(/^I hover over such an image$/) do
  find("img[src='#{model_image_thumb_path(@model, offset: 0)}']").hover
end

Then(/^that image becomes the main image$/) do
  expect(find('#main-image', visible: false)['src'][model_image_path(@model, offset: 0)].blank?).to be false
end

When(/^I hover over another image$/) do
  find("img[src='#{model_image_thumb_path(@model, offset: 1)}']").hover
end

Then(/^that other image becomes the main image$/) do
  expect(find('#main-image', visible: false)['src'][model_image_path(@model, offset: 1)].blank?).to be false
end

When(/^I click on an image$/) do
  find("img[src='#{model_image_thumb_path(@model, offset: 1)}']", visible: false).find(:xpath, './..').click
end

Then(/^that image remains the main image even when I'm not hovering over it$/) do
  step 'I release the focus from this field'
  expect(find('#main-image', visible: false)['src'][model_image_path(@model, offset: 1)]).not_to be_nil
end

Given(/^I see a model's detail page that includes properties$/) do
  @model = @current_user.models.borrowable.detect {|m| m.properties.length > 5}
  visit borrow_model_path @model
end

Then(/^the first five properties are shown with their keys and values$/) do
  @model.properties[0..4].each do |property|
    find('*', match: :first, text: property.key, visible: true)
  end
end

Then(/^I toggle all properties$/) do
  find('#properties-toggle', match: :first).click
end

Then(/^all properties are displayed$/) do
  expect(find('#collapsed-properties', match: :first)['class']['collapsed'].nil?).to be true
end

Then(/^I can use the same toggle to collapse the properties again$/) do
  find('#properties-toggle', match: :first).click
  expect(find('#collapsed-properties', match: :first)['class']['collapsed'].nil?).to be false
end
