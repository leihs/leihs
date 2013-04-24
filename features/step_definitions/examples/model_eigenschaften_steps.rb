# encoding: utf-8

Angenommen /^ich erstelle ein Modell und gebe die Pflichtfelder an$/ do
  step 'ich ein neues Modell hinzufüge'
  step 'ich erfasse die folgenden Details', table(%{
    | Feld                               | Wert                       |
    | Name                               | Test Modell                |
  })
end

Wenn /^ich Eigenschaften hinzufügen und die Felder mit den Platzhaltern Schlüssel und Wert angebe$/ do
  step 'ich die Eigenschaft "Masse" "(20x40cm)" hinzufüge'
  step 'ich die Eigenschaft "Verbrauch" "2kWh" hinzufüge'
  step 'ich die Eigenschaft "Leistung" "40 Watt" hinzufüge'
  step 'ich die Eigenschaft "Farbe" "Blau" hinzufüge'
end

Wenn /^ich die Eigenschaft "(.*?)" "(.*?)" hinzufüge$/ do |k,v|
  find("#add-property").click
  find("[ng-model='property.key'][placeholder='#{_("Key")}']").set k
  find("[ng-model='property.value'][placeholder='#{_("Value")}']").set v
end

Wenn /^ich die Eigenschaften sortiere$/ do
  find(".properties .ui-sortable") # real sorting is not possible with capybara/selenium
  @properties = all(".properties li").map{|li| {:key => li.find("input[ng-model='property.key']").value, :value => li.find("input[ng-model='property.value']").value}}
end

Dann /^sind die Eigenschaften gemäss Sortierreihenfolge für dieses Modell gespeichert$/ do
  wait_until { page.evaluate_script("$.active") == 0 }
  wait_until { all(".line").size > 0 }
  wait_until{ not Model.last.properties.empty? }
  Model.last.properties.each_with_index do |property, i|
    property.key.should == @properties[i][:key]
    property.value.should == @properties[i][:value]
  end
end

Dann /^sind die Eigenschaften gemäss Sortierreihenfolge für das geänderte Modell gespeichert$/ do
  wait_until { page.evaluate_script("$.active") == 0 }
  wait_until { all(".line").size > 0 }
  @model = @model.reload
  @model.properties.size.should == @properties.size
  @model.properties.each_with_index do |property, i|
    property.key.should == @properties[i][:key]
    property.value.should == @properties[i][:value]
  end
end

Angenommen /^ich editiere ein Modell$/ do
  step 'man öffnet die Liste der Modelle'
  step 'ich ein bestehendes Modell bearbeite'
end

Angenommen /^ich editiere ein Modell welches bereits Eigenschaften hat$/ do
  @model = @current_inventory_pool.models.joins(:properties).first
  visit edit_backend_inventory_pool_model_path @current_inventory_pool, @model
end

Wenn /^ich bestehende Eigenschaften ändere$/ do
  find("[ng-model='property.key']").set "Anschluss"
  find("[ng-model='property.value']").set "USB"
end

Wenn /^ich eine oder mehrere bestehende Eigenschaften lösche$/ do
  find(".properties .clickable").click
  @properties = all(".properties li:not(.tobedeleted)").map{|li| {:key => li.find("input[ng-model='property.key']").value, :value => li.find("input[ng-model='property.value']").value}}
end