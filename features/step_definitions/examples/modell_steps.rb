# encoding: utf-8

Angenommen /^man öffnet die Liste der Modelle$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_models_path @current_inventory_pool
end

Wenn(/^ich ein ergänzendes Modell mittel Autocomplete Feld hinzufüge$/) do
  @comp1 = Model.find_by_name "Sharp Beamer"
  @comp2 = Model.find_by_name "Kamera Stativ"
  fill_in_autocomplete_field _("Compatibles"), @comp1.name
  fill_in_autocomplete_field _("Compatibles"), @comp2.name
end

Dann(/^ist dem Modell das ergänzende Modell hinzugefügt worden$/) do
  wait_until { page.has_content? _("List of Models") }
  @model.compatibles.size.should be 2
  @model.compatibles.any? {|m| m.name == @comp1.name}.should be_true
  @model.compatibles.any? {|m| m.name == @comp2.name}.should be_true
end

Wenn(/^ich ein Modell öffne, das bereits ergänzende Modelle hat$/) do
  @model = Model.find_by_name "Walkera v120"
  step 'ich nach "%s" suche' % @model.name
  wait_until { find(".line", :text => @model.name).find(".button", :text => _("Edit Model")) }.click
end

Wenn(/^ich ein ergänzendes Modell entferne$/) do
  within find(".inner", text: _("Compatibles")) do
    all("label", text: _("delete")).each {|comp| comp.click}
  end
end

Dann(/^ist das Modell ohne das gelöschte ergänzende Modell gespeichert$/) do
  wait_until { page.has_content? _("List of Models") }
  @model.reload.compatibles.should be_empty
end
