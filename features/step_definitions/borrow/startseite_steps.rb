# encoding: utf-8

Und(/^man befindet sich auf der Seite der Hauptkategorien$/) do
  visit borrow_start_path
end

Dann(/^sieht man genau die für den User bestimmte Haupt\-Kategorien mit Bild und Namen$/) do
  @main_categories = @current_user.categories.select {|c| c.parents.empty?}
  categories_counter = 0
  @main_categories.each do |mc|
    find("a", text: mc.name)
    categories_counter += 1
  end
  categories_counter.should eq @main_categories.count
end

Und(/^man sieht die Überschrift "(.*?)"$/) do |arg1|
  find ".row a", text: _("Overview")
end

Wenn(/^ich über eine Hauptkategorie mit Kindern fahre$/) do
  @main_category = @current_user.categories.select{|c| c.parents.empty? and not c.children.empty?}.first
  page.execute_script %Q{$('*[data-category_id] .padding-inset-s:contains("#{@main_category.name}")').trigger('mouseenter')}
  page.execute_script %Q{$('*[data-category_id] .padding-inset-s:contains("#{@main_category.name}")').closest('*[data-category_id]').find('.dropdown').show()}
end

Dann(/^sehe ich die Kinder dieser Hauptkategorie$/) do
  second_level_categories = @main_category.children
  @second_level_category = second_level_categories.first
  wait_until {find "a", text: @second_level_category.name}
  within find("*[data-category_id] .padding-inset-s", text: @main_category.name).find(:xpath, "../..").find(".dropdown-holder") do
    second_level_categories.each do |c|
      find(".dropdown a", text: c.name)
    end
  end
end

Wenn(/^ich eines dieser Kinder anwähle$/) do
  click_link @second_level_category.name
end

Dann(/^lande ich in der Modellliste für diese Kategorie$/) do
  expect(current_url =~ Regexp.new(Regexp.escape borrow_models_path(category_id: @second_level_category.id))).not_to be_nil
end
