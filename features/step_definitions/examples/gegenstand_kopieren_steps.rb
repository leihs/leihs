# encoding: utf-8

Angenommen /^man erstellt einen Gegenstand$/ do |table|
  @table_hashes = table.hashes
  step "man navigiert zur Gegenstandserstellungsseite"
  step %{ich alle Informationen erfasse, fuer die ich berechtigt bin}, table
  @inventory_code_original = first(".row.emboss", match: :prefer_exact, text: _("Inventory code")).first("input").value
end

Wenn /^man speichert und kopiert$/ do
  find(".content-wrapper .dropdown-holder", match: :first).hover
  find("a[id='item-save-and-copy']", match: :first).click
end

Dann /^wird der Gegenstand gespeichert$/ do
  page.has_content? _("Create copied item")
  @new_item = Item.find_by_inventory_code(@inventory_code_original)
  @new_item.should_not be_blank
end

Dann /^eine neue Gegenstandserstellungsansicht wird geöffnet$/ do
  current_path.should == manage_copy_item_path(@current_inventory_pool, @new_item.id)
end

Dann /^man sieht den Seitentitel 'Kopierten Gegenstand erstellen'$/ do
  page.has_content? _("Create copied item")
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
        first("input,textarea").value.should == (field_value != "Keine/r" ? field_value : "")
      when "select"
        all("option").detect(&:selected?).text.should == field_value
      when "radio must"
        first("input[checked][type='radio']").value.should == field_value
      when ""
        if not_copied_fields.include? field_name
          if field_name == _("Inventory code")
            first("input,textarea").value.should_not == @inventory_code_original
          else
            first("input,textarea").value.should be_blank
          end
        else
          first("input,textarea").value.should == field_value
        end
      end
    end
  end
end

Dann /^der Inventarcode ist vorausgefüllt$/ do
  @inventory_code_copied = first(".row.emboss", match: :prefer_exact, text: _("Inventory code")).first("input").value
  @inventory_code_copied.should_not be_blank
end

Dann /^wird der kopierte Gegenstand gespeichert$/ do
  page.has_content? _("List of Inventory")
  @copied_item = Item.find_by_inventory_code(@inventory_code_copied)
  @copied_item.should_not be_nil
end

Dann /^man wird zur Liste des Inventars zurückgeführt$/ do
  current_path.should == manage_inventory_path(@current_inventory_pool)
end

Wenn /^man einen Gegenstand kopiert$/ do
  @item = Item.where(inventory_pool_id: @current_inventory_pool).detect {|i| not i.retired? and not i.serial_number.nil? and not i.name.nil?}
  find_field('list-search').set @item.model.name
  step "ensure there are no active requests"
  find(".line[data-type='model'] .col2of5", match: :first, text: @item.model.name)
  first("[data-type='inventory-expander']").click
  find(".line[data-id='#{@item.id}'] .dropdown-holder").hover
  first(".line[data-type='item']", text: @item.inventory_code).first("a", text: _("Copy Item")).click
end

Dann /^wird eine neue Gegenstandskopieransicht geöffnet$/ do
  current_path.should == manage_copy_item_path(@current_inventory_pool, @item)
end

Dann /^alle Felder bis auf Inventarcode, Seriennummer und Name wurden kopiert$/ do
  expect(find(".row.emboss", match: :prefer_exact, text: _("Inventory code")).first("input,textarea").value == @item.inventory_code).to be_false
  expect(find(".row.emboss", match: :prefer_exact, text: _("Inventory code")).first("input,textarea").value.empty?).to be_false
  expect(find(".row.emboss", match: :prefer_exact, text: _("Model")).first("input,textarea").value).to eql @item.model.name
  expect(find(".row.emboss", match: :prefer_exact, text: _("Serial Number")).first("input,textarea").value.empty?).to be_true
  expect(find(".row.emboss", match: :prefer_exact, text: _("Name")).first("input,textarea").value.empty?).to be_true
end

Angenommen /^man befindet sich auf der Gegenstandserstellungsansicht$/ do
  @item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired?}
  find_field('list-search').set @item.model.name
  step "ensure there are no active requests"
  find(".line[data-type='model'] .col2of5", match: :first, text: @item.model.name)
  first("[data-type='inventory-expander']").click
  find(".line[data-id='#{@item.id}'] .dropdown-holder").hover
  first(".line[data-type='item']", text: @item.inventory_code).first(".button", text: _("Edit Item")).click
end

Angenommen /^man editiert ein Gegenstand eines anderen Besitzers$/ do
  @item = Item.find {|i| i.inventory_pool_id == @current_inventory_pool.id and @current_inventory_pool.id != i.owner_id}
  visit "/manage/%d/items/%d/edit" % [@current_inventory_pool.id, @item.id]
  page.has_selector?(".field")
  @fields = all(".field:not(.editable)")
  @fields.size.should > 0
end

Dann /^alle Felder sind editierbar, da man jetzt Besitzer von diesem Gegenstand ist$/ do
  page.has_selector?(".field")
  @fields = all(".field[data-editable='false']")
  @fields.size.should == 0
end

Dann(/^bei dem kopierten Gegestand ist der neue Lieferant eingetragen$/) do
  Item.find_by_inventory_code(@inventory_code).supplier.name.should == @new_supplier
end

Wenn(/^ich merke mir den Inventarcode für weitere Schritte$/) do
  @inventory_code = find(".row.emboss", match: :prefer_exact, text: _("Inventory code")).find("input,textarea").value
end
