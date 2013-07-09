# -*- encoding : utf-8 -*-

Angenommen(/^man befindet sich auf der Seite der Hauptkategorien$/) do
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

Wenn(/^man eine Hauptkategorie auswählt$/) do
  @main_category = @current_user.categories.select {|c| c.parents.empty?}.sample
  find("[data-category_id='#{@main_category.id}'] a").click
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

Dann(/^lande ich in der Modellliste für diese Hauptkategorie$/) do
  expect(current_url =~ Regexp.new(Regexp.escape borrow_models_path(category_id: @main_category.id))).not_to be_nil
end

Dann(/^lande ich in der Modellliste für diese Kategorie$/) do
  expect(current_url =~ Regexp.new(Regexp.escape borrow_models_path(category_id: @second_level_category.id))).not_to be_nil
end

#####################################################################################

Angenommen(/^die letzte Aktivität auf meiner Bestellung ist mehr als (\d+) Stunden her$/) do |arg1|
  @order = @current_user.get_current_order
  @order.update_attributes(updated_at: Time.now - 3.days)
end

Wenn(/^ich die Seite der Hauptkategorien besuche$/) do
  step "man befindet sich auf der Seite der Hauptkategorien"
end

Dann(/^lande ich auf der Bestellung\-Abgelaufen\-Seite$/) do
  current_path.should == borrow_order_timed_out_path
end

Dann(/^ich sehe eine Information, dass die Geräte nicht mehr reserviert sind$/) do
  find("h1", text: _("Your order is older than 24 hours, then it has timed out!"))
  find("h2", text: _("The following items are not reserved any more:"))
end

Wenn(/^ich dies akzeptiere$/) do
  find("a", text: _("Agree")).click
end

Dann(/^wird die Bestellung gelöscht$/) do
  expect { @order.reload }.to raise_error(ActiveRecord::RecordNotFound)
end

Dann(/^ich lande auf der Seite der Hauptkategorien$/) do
  current_path.should == borrow_start_path
end
