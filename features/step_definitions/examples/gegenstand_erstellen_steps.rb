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
          expect(find("input,textarea").value).to eq (field_value != "Keine/r" ? field_value : "")
        when "select"
          expect(all("option").detect(&:selected?).text).to eq field_value
        when "radio must"
          expect(find("input[checked][type='radio']").value).to eq field_value
        when "radio"
          expect(find("label", text: field_value).find("input").checked?).to be true
        else
          expect(find("input,textarea").value).to eq field_value
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
  expect(has_selector?(".row.emboss")).to be true
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
        within matched_field do
          find("input").click
          find("input").set field_value
        end
        find(".ui-autocomplete a", match: :prefer_exact, text: field_value, visible: true).click
      else
        within matched_field do
          find("input,textarea").set ""
          find("input,textarea").set field_value
        end
    end
  end
end

Wenn /^ich erstellen druecke$/ do
  find("button", text: _("Save %s") % _("Item")).click
  find("#flash")
end

Dann /^ist der Gegenstand mit all den angegebenen Informationen erstellt$/ do
  select "true", from: "retired" if @table_hashes.detect { |r| r["Feldname"] == "Ausmusterung" } and (@table_hashes.detect { |r| r["Feldname"] == "Ausmusterung" }["Wert"]) == "Ja"
  inventory_code = @table_hashes.detect { |r| r["Feldname"] == "Inventarcode" }["Wert"]
  find("#list-search").set inventory_code
  sleep(0.11)
  within("#inventory .line[data-type='model']", match: :first, text: /#{@table_hashes.detect { |r| r["Feldname"] == "Modell" }["Wert"]}/) do
    expect(find(".col2of5 strong").text).to match /#{@table_hashes.detect { |r| r["Feldname"] == "Modell" }["Wert"]}/
    find(".button[data-type='inventory-expander'] i.arrow.right").click
    find(".button[data-type='inventory-expander'] i.arrow.down")
  end
  find(".group-of-lines .line[data-type='item']", text: inventory_code).find(".button", text: _("Edit Item")).click
  step 'hat der Gegenstand alle zuvor eingetragenen Werte'
end

Dann /^hat der Gegenstand alle zuvor eingetragenen Werte$/ do
  expect(has_selector?(".row.emboss")).to be true
  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]
    field = Field.all.detect { |f| _(f.label) == field_name }
    find("[data-type='field'][data-id='#{field.id}']", match: :first)
    matched_field = all("[data-type='field'][data-id='#{field.id}']").last
    raise "no field found" if matched_field.blank?
    case field_type
      when "autocomplete"
        expect(matched_field.find("input,textarea").value).to eq (field_value != "Keine/r" ? field_value : "")
      when "select"
        expect(matched_field.all("option").detect(&:selected?).text).to eq field_value
      when "radio must"
        expect(matched_field.find("input[checked][type='radio']").value).to eq field_value
      when ""
        expect(matched_field.find("input,textarea").value).to eq field_value
    end
  end
end

Dann /^man wird zur Liste des Inventars zurueckgefuehrt$/ do
  expect(current_path).to eq manage_inventory_path(@current_inventory_pool)
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
        find(".row.emboss", match: :prefer_exact, text: must_field_name).find("select option[value='']").select_option
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
  expect(Item.find_by_inventory_code("")).to eq nil
  expect(Item.find_by_inventory_code("test")).to eq nil
end

Dann /^die anderen Angaben wurde nicht gelöscht$/ do
  if @must_field_name == "Modell"
    @inventory_code_field.value.should eql @inventory_code_value
    @project_number_field.value.should eql @project_number_value
  end
end

Dann /^ist der Barcode bereits gesetzt$/ do
  expect(find(".row.emboss", match: :prefer_exact, text: "Inventarcode").find("input").value.empty?).to be false
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

Wenn(/^ich einen( nicht)? existierenen Lieferanten angebe$/) do |arg1|
  @suppliers_count = Supplier.count
  if arg1
    @new_supplier = Faker::Lorem.words(rand 1..3).join(' ')
    expect(Supplier.find_by_name(@new_supplier)).to eq nil
  else
    @new_supplier = Supplier.all.sample.name
  end
  find(".row.emboss", match: :prefer_exact, text: _("Supplier")).find("input").set @new_supplier
end

Dann(/^wird (der neue|kein neuer) Lieferant erstellt$/) do |arg1|
  expect(has_content?(_("List of Inventory"))).to be true
  find("#inventory")
  expect(Supplier.find_by_name(@new_supplier)).not_to be nil
  expect(Supplier.where(name: @new_supplier).count).to eq 1
  case arg1
    when "der neue"
      expect(Supplier.count).to eq @suppliers_count + 1
    when "kein neuer"
      expect(Supplier.count).to eq @suppliers_count
  end
end

Dann(/^bei dem (erstellten|bearbeiteten|kopierten) Gegestand ist der (neue|bereits vorhandenen) Lieferant eingetragen$/) do |arg1, arg2|
  expect(
    case arg1
      when "erstellten"
        Item.find_by_inventory_code("test").supplier.name
      when "bearbeiteten"
        case arg2
          when "neue", "bereits vorhandenen"
            @item.reload.supplier.name
        end
      when "kopierten"
        Item.find_by_inventory_code(@inventory_code).supplier.name
    end
  ).to eq @new_supplier
end
