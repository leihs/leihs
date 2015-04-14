# encoding: utf-8

#Angenommen /^ich erstelle ein Modell und gebe die Pflichtfelder an$/ do
Given /^I create a model and fill in all required fields$/ do
  #step 'ich ein neues Modell hinzufüge'
  step 'I add a new Model'
  #step 'ich erfasse die folgenden Details', table(%{
  step 'I enter the following details', table(%{
    | Field   | Value      |
    | Product | Test Model |
  })
end

# Wenn /^ich Eigenschaften hinzufügen und die Felder mit den Platzhaltern Schlüssel und Wert angebe$/ do
When /^I add some properties and fill in their keys and values$/ do
  step 'I add the property "Dimensions" "(20x40cm)"'
  step 'I add the property "Power consumption" "2kWh"'
  step 'I add the property "Power" "40 Watts"'
  step 'I add the property "Color" "Blue"'
end

#Wenn /^ich die Eigenschaft "(.*?)" "(.*?)" hinzufüge$/ do |k,v|
When /^I add the property "(.*?)" "(.*?)"$/ do |k,v|
  find(".button.green", text: _("Save %s") % _("Model"))
  find("#add-property").click
  find("[name='model[properties_attributes][][key]']", match: :first).set k
  find("[name='model[properties_attributes][][value]']", match: :first).set v
end

# Wenn /^ich die Eigenschaften sortiere$/ do
When /^I sort the properties$/ do
  within "#properties" do
    find(".list-of-lines.ui-sortable") # real sorting is not possible with capybara/selenium
    @properties = all(".list-of-lines .line").map{|line| {:key => line.find("input[name='model[properties_attributes][][key]']").value, :value => line.find("input[name='model[properties_attributes][][value]']").value}}
  end
end


#Dann /^sind die Eigenschaften gemäss Sortierreihenfolge für dieses Modell gespeichert$/ do
Then /^this model's properties are saved in the order they were given$/ do
  find(".line", match: :first)
  # can't seem to find the proper model otherwise
  if @model
    model = @model
  else
    model = Model.last
  end
  expect(model.properties.empty?).to be false
  model.properties.each_with_index do |property, i|
    expect(property.key).to eq @properties[i][:key]
    expect(property.value).to eq @properties[i][:value]
  end
end

#Dann /^sind die Eigenschaften gemäss Sortierreihenfolge für das geänderte Modell gespeichert$/ do
Then /^the properties for the changed model are saved in the order they were given$/ do
  find(".line", match: :first)
  @model = @model.reload
  expect(@model.properties.size).to eq @properties.size
  @model.properties.each_with_index do |property, i|
    expect(property.key).to eq @properties[i][:key]
    expect(property.value).to eq @properties[i][:value]
  end
end

#Angenommen /^ich editiere ein Modell$/ do
Given /^I am editing a model$/ do
  step 'I open the inventory'
  step 'I edit a model that exists and is in use'
  find("h1", match: :prefer_exact, text: _("Edit Model"))
end

#Angenommen /^ich editiere ein Modell welches bereits Eigenschaften hat$/ do
Given /^I edit a model that already has properties$/ do
  @model = @current_inventory_pool.models.joins(:properties).first
  visit manage_edit_model_path(@current_inventory_pool, @model)
end

#Wenn /^ich bestehende Eigenschaften ändere$/ do
When /^I change existing properties$/ do
  find("input[name='model[properties_attributes][][key]']", match: :first).set "Connection"
  find("input[name='model[properties_attributes][][value]']", match: :first).set "USB"
end

#Wenn /^ich eine oder mehrere bestehende Eigenschaften lösche$/ do
When /^I delete one or more existing properties$/ do
  within "#properties" do
    find(".list-of-lines .line:not(.striked) .button[data-remove]", match: :first).click
    @properties = all(".list-of-lines .line:not(.striked)").map{|line| {:key => line.find("input[name='model[properties_attributes][][key]']").value, :value => line.find("input[name='model[properties_attributes][][value]']").value}}
  end
end
