# -*- encoding : utf-8 -*-

Dann(/^sehe ich die Brotkrumennavigation$/) do
  expect(has_selector?("nav .navigation-tab-item", text: _("Start"))).to be true
end

Angenommen(/^ich sehe die Brotkrumennavigation$/) do
  step "sehe ich die Brotkrumennavigation"
end

Dann(/^beinhaltet diese immer an erster Stelle das Übersichtsbutton$/) do
  @home_button = all("nav .navigation-tab-item").first
  expect(@home_button.text).to match _("Start")
end

Dann(/^dieser führt mich immer zur Seite der Hauptkategorien$/) do
  @home_button.click
  expect(current_path).to eq borrow_root_path
end

Wenn(/^ich eine Kategorie der ersten stufe aus der Explorativen Suche wähle$/) do
  category_link = find("#explorative-search h2 a", match: :first)
  @category = Category.find_by_name category_link[:title]
  category_link.click
end

Wenn(/^ich eine Unterkategorie wähle$/) do
  page.execute_script %Q{$('*[data-category_id]').trigger('mouseenter')}
  page.execute_script %Q{$('*[data-category_id]').closest('*[data-category_id]').find('.dropdown').show()}
  @category_el = find("a.dropdown-item", match: :first)
  @category_name = @category_el.text
  @category = Category.find_by_name @category_name
  @category_el.click
end

Dann(/^öffnet diese Kategorie$/) do
  expect((Rack::Utils.parse_nested_query URI.parse(current_url).query)["category_id"].to_i).to eq @category.id
end

Wenn(/^ich eine Kategorie der zweiten stufe aus der Explorativen Suche wähle$/) do
  category_link = find("#explorative-search h3 a", match: :first)
  @category = Category.find_by_name category_link[:title]
  category_link.click
end

Wenn(/^ich eine Hauptkategorie wähle$/) do
  category_el = find(".row.emboss.focus-hover", match: :first)
  @category = Category.find_by_name category_el.find("h2", match: :first).text
  category_el.find("a", match: :first).click
end

Dann(/^die Kategorie ist das zweite und letzte Element der Brotkrumennavigation$/) do
  all("nav .navigation-tab-item")[1].text[@category.name].should be
  expect(all("nav .navigation-tab-item").length).to eq 2
end

Wenn(/^ich ein Modell öffne$/) do
  find(".line[data-id]", match: :first).click
end

Dann(/^sehe ich den ganzen Weg den ich zum Modell beschritten habe$/) do
  step 'die Kategorie ist das zweite und letzte Element der Brotkrumennavigation'
end

Dann(/^kein Element der Brotkrumennavigation ist aktiv$/) do
  expect(all("nav .navigation-tab-item.active").length).to eq 0
end