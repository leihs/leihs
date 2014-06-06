# encoding: utf-8

Angenommen /^man erstellt einen Gegenstand$/ do |table|
  @table_hashes = table.hashes
  step "man navigiert zur Gegenstandserstellungsseite"
  step %{ich alle Informationen erfasse, fuer die ich berechtigt bin}, table
  @inventory_code_original = find(".row.emboss", match: :prefer_exact, text: _("Inventory code")).find("input", match: :first).value
end

Wenn /^man speichert und kopiert$/ do
  find(".content-wrapper .dropdown-holder", match: :first).click
  find("a[id='item-save-and-copy']", match: :first).click
end

Dann /^wird der Gegenstand gespeichert$/ do
  page.should have_content _("Create copied item")
  @new_item = Item.find_by_inventory_code(@inventory_code_original)
  @new_item.should_not be_blank
end

Dann /^eine neue Gegenstandserstellungsansicht wird geöffnet$/ do
  current_path.should == manage_copy_item_path(@current_inventory_pool, @new_item.id)
end

Dann /^man sieht den Seitentitel 'Kopierten Gegenstand erstellen'$/ do
  page.should have_content _("Create copied item")
end

Dann /^man sieht den Abbrechen\-Knopf$/ do
  find(".button", match: :first, text: _("Cancel"))
end

Dann /^alle Felder bis auf die folgenden wurden kopiert:$/ do |table|
  not_copied_fields = table.raw.flatten
  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]

    within(".row.emboss", match: :prefer_exact, text: field_name) do
      case field_type
      when "autocomplete"
        find("input,textarea", match: :first).value.should == (field_value != "Keine/r" ? field_value : "")
      when "select"
        all("option").detect(&:selected?).text.should == field_value
      when "radio must"
        find("input[checked][type='radio']", match: :first).value.should == field_value
      when ""
        if not_copied_fields.include? field_name
          if field_name == _("Inventory code")
            find("input,textarea", match: :first).value.should_not == @inventory_code_original
          else
            find("input,textarea", match: :first).value.should be_blank
          end
        else
          find("input,textarea", match: :first).value.should == field_value
        end
      end
    end
  end
end

Dann /^der Inventarcode ist vorausgefüllt$/ do
  @inventory_code_copied = find(".row.emboss", match: :prefer_exact, text: _("Inventory code")).find("input", match: :first).value
  @inventory_code_copied.should_not be_blank
end

Dann /^wird der kopierte Gegenstand gespeichert$/ do
  page.should have_content _("List of Inventory")
  @copied_item = Item.find_by_inventory_code(@inventory_code_copied)
  @copied_item.should_not be_nil
end

Dann /^man wird zur Liste des Inventars zurückgeführt$/ do
  current_path.should == manage_inventory_path(@current_inventory_pool)
end

Wenn /^man einen Gegenstand kopiert$/ do
  @item = Item.where(inventory_pool_id: @current_inventory_pool).detect {|i| not i.retired? and not i.serial_number.nil? and not i.name.nil?}
  find("#list-search").set @item.model.name
  find(".line[data-type='model'] .col2of5", match: :first, text: @item.model.name)
  find("[data-type='inventory-expander']", match: :first).click
  within(".line[data-type='item'][data-id='#{@item.id}']", text: @item.inventory_code) do
    find(".dropdown-holder").click
    find("a", text: _("Copy Item")).click
  end
end

Dann /^wird eine neue Gegenstandskopieransicht geöffnet$/ do
  current_path.should == manage_copy_item_path(@current_inventory_pool, @item)
end

Dann /^alle Felder bis auf Inventarcode, Seriennummer und Name wurden kopiert$/ do
  expect(find(".row.emboss", match: :prefer_exact, text: _("Inventory code")).find("input,textarea", match: :first).value == @item.inventory_code).to be_false
  expect(find(".row.emboss", match: :prefer_exact, text: _("Inventory code")).find("input,textarea", match: :first).value.empty?).to be_false
  expect(find(".row.emboss", match: :prefer_exact, text: _("Model")).find("input,textarea", match: :first).value).to eql @item.model.name
  expect(find(".row.emboss", match: :prefer_exact, text: _("Serial Number")).find("input,textarea", match: :first).value.empty?).to be_true
  expect(find(".row.emboss", match: :prefer_exact, text: _("Name")).find("input,textarea", match: :first).value.empty?).to be_true
end

Angenommen /^man befindet sich auf der Gegenstandserstellungsansicht$/ do
  @item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired?}
  find("#list-search").set @item.model.name
  find(".line[data-type='model'] .col2of5", match: :first, text: @item.model.name)
  find("[data-type='inventory-expander']", match: :first).click
  within(".line[data-type='item'][data-id='#{@item.id}']", text: @item.inventory_code) do
    find(".dropdown-holder").click
    find(".button", text: _("Edit Item")).click
  end
end

Angenommen /^man editiert ein Gegenstand eines anderen Besitzers$/ do
  @item = Item.find {|i| i.inventory_pool_id == @current_inventory_pool.id and @current_inventory_pool.id != i.owner_id}
  visit manage_edit_item_path(@current_inventory_pool, @item)
  page.should have_selector(".field")
  @fields = all(".field:not(.editable)")
  @fields.size.should > 0
end

Dann /^alle Felder sind editierbar, da man jetzt Besitzer von diesem Gegenstand ist$/ do
  page.should have_selector(".field")
  @fields = all(".field[data-editable='false']")
  @fields.size.should == 0
end

Dann(/^bei dem kopierten Gegestand ist der neue Lieferant eingetragen$/) do
  Item.find_by_inventory_code(@inventory_code).supplier.name.should == @new_supplier
end

Wenn(/^ich merke mir den Inventarcode für weitere Schritte$/) do
  @inventory_code = find(".row.emboss", match: :prefer_exact, text: _("Inventory code")).find("input,textarea").value
end
