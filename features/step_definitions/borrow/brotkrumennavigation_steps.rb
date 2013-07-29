# -*- encoding : utf-8 -*-

Dann(/^sehe ich die Brotkrumennavigation$/) do
  page.should have_selector "nav .navigation-tab-item", text: _("Start")
end

Angenommen(/^ich sehe die Brotkrumennavigation$/) do
  step "sehe ich die Brotkrumennavigation"
end

Dann(/^beinhaltet diese immer an erster Stelle das Übersichtsbutton$/) do
  @home_button = all("nav .navigation-tab-item").first
  @home_button.text.should match _("Start")
end

Dann(/^dieser führt mich immer zur Seite der Hauptkategorien$/) do
  @home_button.click
  current_path.should eq borrow_root_path
end

Wenn(/^ich eine Kategorie der ersten stufe aus der Explorativen Suche wähle$/) do
  category_link = find("#explorative-search h2 a")
  @category = Category.find_by_name category_link[:title]
  category_link.click
end

Wenn(/^ich eine Unterkategorie wähle$/) do
  page.execute_script %Q{$('*[data-category_id]').trigger('mouseenter')}
  page.execute_script %Q{$('*[data-category_id]').closest('*[data-category_id]').find('.dropdown').show()}
  @category_el = find("a.dropdown-item")
  @category_name = @category_el.text
  @category = Category.find_by_name @category_name
  @category_el.click
end

Dann(/^öffnet diese Kategorie$/) do
  (Rack::Utils.parse_nested_query URI.parse(current_url).query)["category_id"].to_i.should == @category.id
end

Wenn(/^ich eine Kategorie der zweiten stufe aus der Explorativen Suche wähle$/) do
  category_link = find("#explorative-search h3 a")
  @category = Category.find_by_name category_link[:title]
  category_link.click
end

Wenn(/^ich eine Hauptkategorie wähle$/) do
  category_el = find(".row.emboss.focus-hover")
  @category = Category.find_by_name category_el.find("h2").text
  category_el.find("a").click
end

Dann(/^die Kategorie ist das zweite und letzte Element der Brotkrumennavigation$/) do
  all("nav .navigation-tab-item")[1].text[@category.name].should be
  all("nav .navigation-tab-item").length.should == 2
end

Wenn(/^ich ein Modell öffne$/) do
  find(".line[data-id]").click
end

Dann(/^sehe ich den ganzen Weg den ich zum Modell beschritten habe$/) do
  step 'die Kategorie ist das zweite und letzte Element der Brotkrumennavigation'
end

Dann(/^kein Element der Brotkrumennavigation ist aktiv$/) do
  all("nav .navigation-tab-item.active").length.should == 0
end