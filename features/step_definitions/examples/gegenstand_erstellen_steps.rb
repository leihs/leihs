# encoding: utf-8

def fill_in_autocomplete_field field_name, field_value
  find(".field", text: field_name).find("input").set field_value
  find(".field", text: field_name).find("input").click
  wait_until {not all("a", text: field_value).empty?}
  find(".field", text: field_name).find("a", text: field_value).click
end

def check_fields_and_their_values table
  table.hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]

    within find(".field", text: field_name) do
      case field_type
      when "autocomplete"
        find("input,textarea").value.should == (field_value != "Keine/r" ? field_value : "")
      when "select"
        all("option").detect(&:selected?).text.should == field_value
      when "radio must"
        find("input[checked][type='radio']").value.should == field_value
      when ""
        find("input,textarea").value.should == field_value
      end
    end
  end
end

Angenommen /^man merkt sich das aktuelle Inventarpool für weitere Schritte$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools
end

Angenommen /^man befindet sich auf der Liste des Inventars$/ do
  visit backend_inventory_pool_models_path(@current_inventory_pool)
end

Dann /^kann man einen Gegenstand erstellen$/ do
  page.execute_script("$('.content_navigation .arrow').trigger('mouseover');")
  click_link _("Create %s") % _("Item")
  current_path.should eql new_backend_inventory_pool_item_path(@current_inventory_pool)
end

Angenommen /^man navigiert zur Gegenstandserstellungsseite$/ do
  visit new_backend_inventory_pool_item_path(@current_inventory_pool)
end

Wenn /^ich alle Informationen erfasse, fuer die ich berechtigt bin$/ do |table|
  @table_hashes = table.hashes

  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]

    case field_type
    when "radio must"
      find(".field", text: field_name).find("input[value='#{field_value}']").set true
    when "checkbox"
      find(".field", text: field_name).find("input").set true if field_value == "checked"
    when "select"
      find(".field", text: field_name).select field_value
    when "autocomplete"
      find(".field", text: field_name).find("input").set field_value
      find(".field", text: field_name).find("input").click
      wait_until {not all("a", text: field_value).empty?}
      find(".field", text: field_name).find("a", text: field_value).click
    else
      find(".field", text: field_name).find("input,textarea").set field_value
    end
  end
end

Wenn /^ich erstellen druecke$/ do
  find("button", text: _("Create %s") % _("Item")).click
  step "ensure there are no active requests"
end

Dann /^ist der Gegenstand mit all den angegebenen Informationen erstellt$/ do
  find("a[data-tab*='retired']").click if (@table_hashes.detect {|r| r["Feldname"] == "Ausmusterung"} ["Wert"]) == "checked"
  find_field('query').set (@table_hashes.detect {|r| r["Feldname"] == "Inventarcode"} ["Wert"])
  wait_until { all("li.modelname").first.text =~ /#{@table_hashes.detect {|r| r["Feldname"] == "Modell"} ["Wert"]}/ }
  find(".toggle .icon").click
  find(".button", text: 'Gegenstand editieren').click

  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]

    within find(".field", text: field_name) do
      case field_type
      when "autocomplete"
        find("input,textarea").value.should == (field_value != "Keine/r" ? field_value : "")
      when "select"
        all("option").detect(&:selected?).text.should == field_value
      when "radio must"
        find("input[checked][type='radio']").value.should == field_value
      when ""
        find("input,textarea").value.should == field_value
      end
    end
  end
end

Dann /^man wird zur Liste des Inventars zurueckgefuehrt$/ do
  wait_until {current_path.should eql backend_inventory_pool_models_path(@current_inventory_pool)}
end

Wenn /^jedes Pflichtfeld ist gesetzt$/ do |table|
  table.raw.flatten.each do |must_field_name|
    case must_field_name
    when "Inventarcode"
      @inventory_code_value = "test"
      @inventory_code_field = find(".field", text: must_field_name).find("input,textarea")
      @inventory_code_field.set @inventory_code_value
    when "Modell"
      model_name = Model.first.name
      fill_in_autocomplete_field must_field_name, model_name
    when "Projektnummer"
      find(".field", text: "Bezug").find("input[value='investment']").set true
      @project_number_value = "test"
      @project_number_field = find(".field", text: must_field_name).find("input,textarea")
      @project_number_field.set @project_number_value
    end
  end
end

Wenn /^kein Pflichtfeld ist gesetzt$/ do |table|
  table.raw.flatten.each do |must_field_name|
    case must_field_name
    when "Inventarcode"
      find(".field", text: must_field_name).find("input,textarea").set ""
    when "Projektnummer"
      find(".field", text: "Bezug").find("input[value='investment']").set true
      find(".field", text: must_field_name).find("input,textarea").set ""
    end
  end
end

Wenn /^ich das gekennzeichnete (.+) leer lasse$/ do |must_field_name|
  @must_field_name = must_field_name
  find(".field", text: @must_field_name).find("input,textarea").set ""
end

Dann /^kann das Modell nicht erstellt werden$/ do
  step "ich erstellen druecke"
  step "ensure there are no active requests"
  Item.find_by_inventory_code("").should be_nil
  Item.find_by_inventory_code("test").should be_nil
end

Dann /^die anderen Angaben wurde nicht gelöscht$/ do
  if @must_field_name == "Modell"
    @inventory_code_field.value.should eql @inventory_code_value
    @project_number_field.value.should eql @project_number_value
  end
end

Dann /^ist der Barcode bereits gesetzt$/ do
  find(".field", text: "Inventarcode").find("input").value.should_not be_empty
end

Dann /^Letzte Inventur ist das heutige Datum$/ do
  find(".field", text: "Letzte Inventur").find("input").value.should eq Date.today.strftime("%d.%m.%Y")
end

Dann /^folgende Felder haben folgende Standardwerte$/ do |table|
  check_fields_and_their_values table
end
