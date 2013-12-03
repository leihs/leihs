# encoding: utf-8

def fill_in_autocomplete_field field_name, field_value
  within("form .row.emboss", match: :prefer_exact, text: field_name) do
    find("input", match: :first).set ""
    find("input", match: :first).set field_value
  end
  find("a", match: :prefer_exact, text: field_value, visible: true).click
end

def check_fields_and_their_values table
  table.hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]

    within(".row.emboss", match: :prefer_exact, text: field_name) do
      case field_type
      when "autocomplete"
        find("input,textarea").value.should == (field_value != "Keine/r" ? field_value : "")
      when "select"
        all("option").detect(&:selected?).text.should == field_value
      when "radio must"
        find("input[checked][type='radio']").value.should == field_value
      when "radio"
        find("label", text: field_value).find("input").checked?.should be_true
      else
        find("input,textarea").value.should == field_value
      end
    end
  end
end

Angenommen /^man befindet sich auf der Liste des Inventars$/ do
  visit manage_inventory_path(@current_inventory_pool)
end

Dann /^kann man einen Gegenstand erstellen$/ do
  step 'ich einen neuen Gegenstand hinzufüge'
  current_path.should eql manage_new_item_path(@current_inventory_pool)
end

Angenommen /^man navigiert zur Gegenstandserstellungsseite$/ do
  visit manage_new_item_path(@current_inventory_pool)
  page.has_selector?(".row.emboss")
end

Wenn /^ich die folgenden Informationen erfasse$/ do |table|
  @table_hashes = table.hashes

  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]
    matched_field = all(".row.emboss", match: :prefer_exact, text: field_name).last
    case field_type
      when "radio", "radio must"
        field_value = true if field_value == "OK"
        matched_field.find("input[value='#{field_value}']").set true
      when "checkbox"
        matched_field.find("input").set (field_value == "checked")
      when "select"
        matched_field.select field_value
      when "autocomplete"
        find("form .field", match: :prefer_exact, text: field_name)
        matched_field.find("input").click
        matched_field.find("input").set field_value
        find(".ui-autocomplete a", match: :prefer_exact, text: field_value, visible: true).click
      else
        matched_field.find("input,textarea").set ""
        matched_field.find("input,textarea").set field_value
    end
  end
end

Wenn /^ich erstellen druecke$/ do
  find("button", text: _("Save %s") % _("Item")).click
  find("#flash")
end

Dann /^ist der Gegenstand mit all den angegebenen Informationen erstellt$/ do
  find("#list-tabs a[data-retired='true']").click if @table_hashes.detect {|r| r["Feldname"] == "Ausmusterung"} and (@table_hashes.detect {|r| r["Feldname"] == "Ausmusterung"}["Wert"]) == "Ja"
  inventory_code = @table_hashes.detect {|r| r["Feldname"] == "Inventarcode"}["Wert"]
  find("#list-search").set inventory_code
  within("#inventory .line[data-type='model']", match: :first, text: /#{@table_hashes.detect {|r| r["Feldname"] == "Modell"}["Wert"]}/) do
    find(".col2of5 strong").text.should =~ /#{@table_hashes.detect {|r| r["Feldname"] == "Modell"}["Wert"]}/
    find(".button[data-type='inventory-expander'] i.arrow.right").click
    find(".button[data-type='inventory-expander'] i.arrow.down")
  end
  find(".group-of-lines .line[data-type='item']", text: inventory_code).find(".button", text: _("Edit Item")).click
  step 'hat der Gegenstand alle zuvor eingetragenen Werte'
end

Dann /^hat der Gegenstand alle zuvor eingetragenen Werte$/ do
  page.has_selector? ".row.emboss"
  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]
    field = Field.all.detect{|f| _(f.label) == field_name}
    find("[data-type='field'][data-id='#{field.id}']", match: :first)
    matched_field = all("[data-type='field'][data-id='#{field.id}']").last
    raise "no field found" if matched_field.blank?
    case field_type
      when "autocomplete"
        matched_field.find("input,textarea").value.should == (field_value != "Keine/r" ? field_value : "")
      when "select"
        matched_field.all("option").detect(&:selected?).text.should == field_value
      when "radio must"
        matched_field.find("input[checked][type='radio']").value.should == field_value
      when ""
        matched_field.find("input,textarea").value.should == field_value
    end
  end
end

Dann /^man wird zur Liste des Inventars zurueckgefuehrt$/ do
  current_path.should eql manage_inventory_path(@current_inventory_pool)
end

Wenn /^jedes Pflichtfeld ist gesetzt$/ do |table|
  table.raw.flatten.each do |must_field_name|
    case must_field_name
    when "Inventarcode"
      @inventory_code_value = "test"
      @inventory_code_field = find(".row.emboss", match: :prefer_exact, text: must_field_name).find("input,textarea")
      @inventory_code_field.set @inventory_code_value
    when "Modell"
      model_name = Model.first.name
      fill_in_autocomplete_field must_field_name, model_name
    when "Projektnummer"
      find(".row.emboss", match: :prefer_exact, text: "Bezug").find("input[value='investment']").set true
      @project_number_value = "test"
      @project_number_field = find(".row.emboss", match: :prefer_exact, text: must_field_name).find("input,textarea")
      @project_number_field.set @project_number_value
    when "Anschaffungskategorie"
      find(".row.emboss", match: :prefer_exact, text: "Anschaffungskategorie").find("select option:not([value=''])", match: :first).select_option
    else
      raise 'unknown field'
    end
  end
end

Wenn /^kein Pflichtfeld ist gesetzt$/ do |table|
  table.raw.flatten.each do |must_field_name|
    case must_field_name
      when "Inventarcode"
        find(".row.emboss", match: :prefer_exact, text: must_field_name).find("input,textarea").set ""
      when "Modell"
        find(".row.emboss", match: :prefer_exact, text: must_field_name).find("input").set ""
      when "Projektnummer"
        find(".row.emboss", match: :prefer_exact, text: "Bezug").find("input[value='investment']").set true
        find(".row.emboss", match: :prefer_exact, text: must_field_name).find("input,textarea").set ""
      when "Anschaffungskategorie"
        find(".row.emboss", match: :prefer_exact, text: "Anschaffungskategorie").find("select option[value='']").select_option
      else
        raise 'unknown field'
    end
  end
end

Wenn /^ich das gekennzeichnete "(.+)" leer lasse$/ do |must_field_name|
  @must_field_name = must_field_name
  if not find(".row.emboss", match: :prefer_exact, text: @must_field_name).all("input,textarea").empty?
    field_id = find(".row.emboss", match: :prefer_exact, text: @must_field_name)["data-id"]
    find(".row.emboss", match: :prefer_exact, text: @must_field_name).find("input,textarea").set ""
    page.execute_script %Q{ $(".field[data-id=#{field_id}] input[data-type='autocomplete']").trigger("change") }
  elsif not find(".row.emboss", match: :prefer_exact, text: @must_field_name).all("select").empty?
    find(".row.emboss", match: :prefer_exact, text: @must_field_name).find("select option[value='']").select_option
  else
    raise "unkown field"
  end
end

Dann /^kann das Modell nicht erstellt werden$/ do
  step "ich erstellen druecke"
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
  find(".row.emboss", match: :prefer_exact, text: "Inventarcode").find("input").value.should_not be_empty
end

Dann /^Letzte Inventur ist das heutige Datum$/ do
  find(".row.emboss", match: :prefer_exact, text: "Letzte Inventur").find("input").value.should eq Date.today.strftime("%d.%m.%Y")
end

Dann /^folgende Felder haben folgende Standardwerte$/ do |table|
  check_fields_and_their_values table
end

Angenommen(/^man setzt Bezug auf Investition$/) do
  find("input[name='item[properties][reference]'][value='investment']").click
end

Dann(/^sind die folgenden Werte im Feld Anschaffungskategorie hinterlegt$/) do |table|
  @table_hashes = table.hashes
  @table_hashes.each do |hash|
    find("select[name='item[properties][anschaffungskategorie]'] option[value='#{hash.values.first}']").select_option
  end
end

Angenommen(/^ich befinde mich auf der Erstellungsseite eines Gegenstandes$/) do
  visit manage_new_item_path(@current_inventory_pool)
end

Wenn(/^ich einen nicht existierenen Lieferanten angebe$/) do
  @new_supplier = Faker::Lorem.words(rand 1..3).join(' ')
  Supplier.find_by_name(@new_supplier).should be_nil
  find(".row.emboss", match: :prefer_exact, text: _("Supplier")).find("input").set @new_supplier
end

Dann(/^wird der neue Lieferant erstellt$/) do
  page.should have_content _("List of Inventory")
  Supplier.find_by_name(@new_supplier).should_not be_nil
end

Dann(/^bei dem erstellten Gegestand ist der neue Lieferant eingetragen$/) do
  Item.find_by_inventory_code("test").supplier.name.should == @new_supplier
end
