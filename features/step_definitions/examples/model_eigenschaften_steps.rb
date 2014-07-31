# encoding: utf-8

Angenommen /^ich erstelle ein Modell und gebe die Pflichtfelder an$/ do
  step 'ich ein neues Modell hinzufüge'
  step 'ich erfasse die folgenden Details', table(%{
    | Feld                               | Wert                       |
    | Produkt                            | Test Modell                |
  })
end

Wenn /^ich Eigenschaften hinzufügen und die Felder mit den Platzhaltern Schlüssel und Wert angebe$/ do
  step 'ich die Eigenschaft "Masse" "(20x40cm)" hinzufüge'
  step 'ich die Eigenschaft "Verbrauch" "2kWh" hinzufüge'
  step 'ich die Eigenschaft "Leistung" "40 Watt" hinzufüge'
  step 'ich die Eigenschaft "Farbe" "Blau" hinzufüge'
end

Wenn /^ich die Eigenschaft "(.*?)" "(.*?)" hinzufüge$/ do |k,v|
  find(".button.green", text: _("Save %s") % _("Model"))
  find("#add-property").click
  find("[name='model[properties_attributes][][key]']", match: :first).set k
  find("[name='model[properties_attributes][][value]']", match: :first).set v
end

Wenn /^ich die Eigenschaften sortiere$/ do
  find("#properties .list-of-lines.ui-sortable") # real sorting is not possible with capybara/selenium
  @properties = all("#properties .list-of-lines .line").map{|line| {:key => line.find("input[name='model[properties_attributes][][key]']").value, :value => line.find("input[name='model[properties_attributes][][value]']").value}}
end

Dann /^sind die Eigenschaften gemäss Sortierreihenfolge für dieses Modell gespeichert$/ do
  find(".line", match: :first)
  all(".line").size.should > 0
  expect(Model.last.properties.empty?).to be false
  Model.last.properties.each_with_index do |property, i|
    expect(property.key).to eq @properties[i][:key]
    expect(property.value).to eq @properties[i][:value]
  end
end

Dann /^sind die Eigenschaften gemäss Sortierreihenfolge für das geänderte Modell gespeichert$/ do
  find(".line", match: :first)
  all(".line").size.should > 0
  @model = @model.reload
  expect(@model.properties.size).to eq @properties.size
  @model.properties.each_with_index do |property, i|
    expect(property.key).to eq @properties[i][:key]
    expect(property.value).to eq @properties[i][:value]
  end
end

Angenommen /^ich editiere ein Modell$/ do
  step 'man öffnet die Liste des Inventars'
  step 'ich ein bestehendes Modell bearbeite'
  find("h1", match: :prefer_exact, text: _("Edit Model"))
end

Angenommen /^ich editiere ein Modell welches bereits Eigenschaften hat$/ do
  @model = @current_inventory_pool.models.joins(:properties).first
  visit manage_edit_model_path(@current_inventory_pool, @model)
end

Wenn /^ich bestehende Eigenschaften ändere$/ do
  find("input[name='model[properties_attributes][][key]']", match: :first).set "Anschluss"
  find("input[name='model[properties_attributes][][value]']", match: :first).set "USB"
end

Wenn /^ich eine oder mehrere bestehende Eigenschaften lösche$/ do
  find("#properties .list-of-lines .line:not(.striked) .button[data-remove]", match: :first).click
  @properties = all("#properties .list-of-lines .line:not(.striked)").map{|line| {:key => line.find("input[name='model[properties_attributes][][key]']").value, :value => line.find("input[name='model[properties_attributes][][value]']").value}}
end
