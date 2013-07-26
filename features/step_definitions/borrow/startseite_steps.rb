# -*- encoding : utf-8 -*-

Angenommen(/^man befindet sich auf der Seite der Hauptkategorien$/) do
  visit borrow_root_path
end

Dann(/^sieht man genau die für den User bestimmte Haupt\-Kategorien mit Bild und Namen$/) do
  @main_categories = @current_user.all_categories.select {|c| c.parents.empty?}
  categories_counter = 0
  @main_categories.each do |mc|
    find("a", text: mc.name)
    categories_counter += 1
  end
  categories_counter.should eq @main_categories.count
end

Wenn(/^man eine Hauptkategorie auswählt$/) do
  @main_category = @current_user.categories.select {|c| c.parents.empty?}.sample
  find("[data-category_id='#{@main_category.id}'] a").click
end

Und(/^man sieht die Überschrift "(.*?)"$/) do |arg1|
  find ".row a", text: _("Start")
end

Wenn(/^ich über eine Hauptkategorie mit Kindern fahre$/) do
  @main_category = (@current_user.all_categories & Category.roots).find do |c|
    borrowable_children = (Category.with_borrowable_models_for_user(@current_user) & c.children)
    c.children.size != borrowable_children.size and borrowable_children.size > 0
  end
  page.execute_script %Q{$('*[data-category_id] .padding-inset-s:contains("#{@main_category.name}")').trigger('mouseenter')}
  page.execute_script %Q{$('*[data-category_id] .padding-inset-s:contains("#{@main_category.name}")').closest('*[data-category_id]').find('.dropdown').show()}
end

Dann(/^sehe ich nur die Kinder dieser Hauptkategorie, die dem User zur Verfügung stehende Gegenstände enthalten$/) do
  second_level_categories = @main_category.children
  visible_2nd_level_categories = (Category.with_borrowable_models_for_user(@current_user) & @main_category.children)
  @second_level_category = visible_2nd_level_categories.first
  wait_until {find "a", text: @second_level_category.name}

  visible_2nd_level_categories_count = 0
  within find("*[data-category_id] .padding-inset-s", text: @main_category.name).find(:xpath, "../..").find(".dropdown-holder") do
    visible_2nd_level_categories.each do |c|
      find(".dropdown a", text: c.name)
      visible_2nd_level_categories_count += 1
    end
  end

  visible_2nd_level_categories_count.should == visible_2nd_level_categories.size
end

Wenn(/^ich eines dieser Kinder anwähle$/) do
  click_link @second_level_category.name
end

Dann(/^lande ich in der Modellliste für diese Hauptkategorie$/) do
  (Rack::Utils.parse_nested_query URI.parse(current_url).query)["category_id"].to_i.should == @main_category.id
end

Dann(/^lande ich in der Modellliste für diese Kategorie$/) do
  (Rack::Utils.parse_nested_query URI.parse(current_url).query)["category_id"].to_i.should == @second_level_category.id
end

Angenommen(/^es gibt eine Hauptkategorie, derer Kinderkategorien keine dem User zur Verfügung stehende Gegenstände enthalten$/) do
  @main_category = (@current_user.all_categories & Category.roots).find do |c|
    (Category.with_borrowable_models_for_user(@current_user) & c.children).size == 0
  end
end

Dann(/^hat diese Hauptkategorie keine Kinderkategorie\-Dropdown$/) do
  find(".row.emboss.focus-hover", text: @main_category.name).should_not have_selector ".dropdown-holder"
end
