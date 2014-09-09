# encoding: utf-8

Wenn /^ich mindestens die Pflichtfelder ausfülle$/ do
  @model_name = "Test Modell-Paket"
  find(".row.emboss", match: :prefer_exact, :text => _("Product")).fill_in 'model[product]', :with => @model_name
end

Wenn /^ich eines oder mehrere Pakete hinzufüge$/ do
  find("button", match: :prefer_exact, text: _("Add %s") % _("Package")).click
end

Wenn /^ich(?: kann | )diesem Paket eines oder mehrere Gegenstände hinzufügen$/ do
  find(".modal #search-item").set "beam123"
  find("a", match: :prefer_exact, text: "beam123").click
  find(".modal #search-item").set "beam345"
  find("a", match: :prefer_exact, text: "beam345").click

  # check that the retired items are excluded from autocomplete search. pivotal bug 69161270
  find(".modal #search-item").set "Bose"
  find("a", match: :prefer_exact, text: "Bose").click
end

Dann /^ist das Modell erstellt und die Pakete und dessen zugeteilten Gegenstände gespeichert$/ do
  expect(has_selector?(".success")).to be true
  @model = Model.find {|m| [m.name, m.product].include? @model_name}
  expect(@model.nil?).to be false
  expect(@model.is_package?).to be true
  @packages = @model.items
  @packages.count.should eq 1
  @packages.first.children.first.inventory_code.should eql "beam123"
  @packages.first.children.second.inventory_code.should eql "beam345"
end

Dann /^den Paketen wird ein Inventarcode zugewiesen$/ do
  expect(@packages.first.inventory_code).not_to be nil
end

Wenn /^das Paket zurzeit nicht ausgeliehen ist$/ do
  @package = @current_inventory_pool.items.packages.in_stock.first
  visit manage_edit_model_path(@current_inventory_pool, @package.model)
end

Dann /^kann ich das Paket löschen und die Gegenstände sind nicht mehr dem Paket zugeteilt$/ do
  @package_item_ids = @package.children.map(&:id)
  find("[data-type='inline-entry'][data-id='#{@package.id}'] [data-remove]").click
  step 'ich speichere die Informationen'
  find("#flash")
  expect(Item.find_by_id(@package.id).nil?).to be true
  lambda {@package.reload}.should raise_error(ActiveRecord::RecordNotFound)
  expect(@package_item_ids.size).to be > 0
  @package_item_ids.each do |id|
    expect(Item.find(id).parent_id).to eq nil
  end
end

Wenn /^das Paket zurzeit ausgeliehen ist$/ do
  @package_not_in_stock = @current_inventory_pool.items.packages.not_in_stock.first
  visit manage_edit_model_path(@current_inventory_pool, @package_not_in_stock.model)
end

Dann /^kann ich das Paket nicht löschen$/ do
  expect(has_no_selector?("[data-type='inline-entry'][data-id='#{@package_not_in_stock.id}'] [data-remove]")).to be true
end

Wenn /^ich ein Modell editiere, welches bereits Pakete( in meine und andere Gerätepark)? hat$/ do |arg1|
  visit manage_inventory_path(@current_inventory_pool)
  @model = @current_inventory_pool.models.shuffle.detect do |m|
    b = (not m.items.empty? and m.is_package?)
    if arg1
      b = (b and m.items.map(&:inventory_pool_id).uniq.size > 1)
    end
    b
  end
  expect(@model).not_to be nil
  @model_name = @model.name
  step 'ich nach "%s" suche' % @model.name
  expect(has_selector?(".line", text: @model.name)).to be true
  find(".line", match: :prefer_exact, :text => @model.name).find(".button", match: :first, :text => _("Edit Model")).click
end

Wenn /^ich ein Modell editiere, welches bereits Gegenstände hat$/ do
  visit manage_inventory_path(@current_inventory_pool)
  @model = @current_inventory_pool.models.detect {|m| not (m.items.empty? and m.is_package?)}
  @model_name = @model.name
  step 'ich nach "%s" suche' % @model.name
  expect(has_selector?(".line", text: @model.name)).to be true
  find(".line", match: :prefer_exact, :text => @model.name).find(".button", match: :first, :text => _("Edit Model")).click
end

Dann /^kann ich diesem Modell keine Pakete mehr zuweisen$/ do
  expect(has_no_selector?("a", text: _("Add %s") % _("Package"))).to be true
end

Wenn /^ich einem Modell ein Paket hinzufüge$/ do
  step "ich ein neues Modell hinzufüge"
  step 'ich mindestens die Pflichtfelder ausfülle'
  step "ich eines oder mehrere Pakete hinzufüge"
end

Dann /^kann ich dieses Paket nur speichern, wenn dem Paket auch Gegenstände zugeteilt sind$/ do
  find("#save-package").click
  expect(has_content?(_("You can not create a package without any item"))).to be true
  expect(has_content?(_("New Package"))).to be true
  find(".modal-close").click
  expect(has_no_selector?("[data-type='field-inline-entry']")).to be true
end

Wenn /^ich ein Paket editiere$/ do
  @model = Model.find {|m| [m.name, m.product].include?"Kamera Set" }
  visit manage_edit_model_path(@current_inventory_pool, @model)
  @package_to_edit = @model.items.detect &:in_stock?
  find(".line[data-id='#{@package_to_edit.id}']").find("button[data-edit-package]").click
end

Dann /^kann ich einen Gegenstand aus dem Paket entfernen$/ do
  within ".modal" do
    within "#items" do
      find("[data-type='inline-entry']", match: :first)
      items = all("[data-type='inline-entry']")
      @number_of_items_before = items.size
      @item_to_remove = items.first.text
      find("[data-remove]", match: :first).click
    end
    find("#save-package").click
  end
  step 'ich speichere die Informationen'
end

Dann /^dieser Gegenstand ist nicht mehr dem Paket zugeteilt$/ do
  expect(has_content?(_("List of Inventory"))).to be true
  @package_to_edit.reload
  @package_to_edit.children.count.should eq (@number_of_items_before - 1)
  expect(@package_to_edit.children.detect {|i| i.inventory_code == @item_to_remove}).to eq nil
end

Dann /^werden die folgenden Felder angezeigt$/ do |table|
  values = table.raw.map do |x|
    x.first.gsub(/^\-\ |\ \-$/, '')
  end
  expect(page.text).to match Regexp.new(values.join('.*'), Regexp::MULTILINE)
end

Wenn /^ich das Paket speichere$/ do
  find(".modal #save-package", match: :first).click
end

Wenn /^ich das Paket und das Modell speichere$/ do
  step 'ich das Paket speichere'
  find("button#save", match: :first).click
end

Dann /^besitzt das Paket alle angegebenen Informationen$/ do
  sleep(0.33)
  model = Model.find {|m| [m.name, m.product].include? @model_name}
  visit manage_edit_model_path(@current_inventory_pool, model)
  model.items.where(inventory_pool: @current_inventory_pool).each do |item|
    expect(has_selector?(".line[data-id='#{item.id}']", visible: false)).to be true
  end
  expect(has_no_selector?("[src*='loading']")).to be true
  @package ||= model.items.packages.first
  find(".line[data-id='#{@package.id}']").find("button[data-edit-package]").click
  expect(has_selector?(".modal .row.emboss")).to be true
  step 'hat das Paket alle zuvor eingetragenen Werte'
end

Wenn /^ich ein bestehendes Paket editiere$/ do
  if @model
    @package = @model.items.packages.sample
    find("#packages .line[data-id='#{@package.id}'] [data-edit-package]").click
  else
    find("#packages .line[data-new] [data-edit-package]", match: :first).click
  end
  find(".modal")
  find(".modal [data-type='field']", match: :first)
end

Wenn(/^ich eine Paket hinzufüge$/) do
  find("#add-package").click
  find(".modal")
  find(".modal [data-type='field']", match: :first)
end

Wenn(/^ich die Paketeigenschaften eintrage$/) do
  steps %Q{Und ich die folgenden Informationen erfasse
    | Feldname                     | Type         | Wert                          |
    | Zustand                      | radio        | OK                            |
    | Vollständigkeit              | radio        | OK                            |
    | Ausleihbar                   | radio        | OK                            |
    | Inventarrelevant             | select       | Ja                            |
    | Letzte Inventur              |              | 01.01.2013                    |
    | Verantwortliche Abteilung    | autocomplete | A-Ausleihe                    |
    | Verantwortliche Person       |              | Matus Kmit                    |
    | Benutzer/Verwendung          |              | Test Verwendung               |
    | Name                         |              | Test Name                     |
    | Notiz                        |              | Test Notiz                    |
    | Gebäude                      | autocomplete | Keine/r                       |
    | Raum                         |              | Test Raum                     |
    | Gestell                      |              | Test Gestell                  |
    | Anschaffungswert             |              | 50.00                         |}
end

Wenn(/^ich dieses Paket speichere$/) do
  find("#save-package").click
end

Wenn(/^ich dieses Paket wieder editiere$/) do
  step 'ich ein bestehendes Paket editiere'
end

Dann(/^kann ich die Paketeigenschaften erneut bearbeiten$/) do
  step 'ich die Paketeigenschaften eintrage'
end

Dann(/^sehe ich die Meldung "(.*?)"$/) do |text|
  find("#flash", match: :prefer_exact, :text => text)
end

Dann /^hat das Paket alle zuvor eingetragenen Werte$/ do
  expect(has_selector?(".modal .row.emboss")).to be true
  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]
    field = Field.all.detect{|f| _(f.label) == field_name}
    within ".modal" do
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
end

Then(/^all the packaged items receive these same values store to this package$/) do |table|
  table.hashes.each do |t|
    b = @package.children.all? {|c|
      case t[:Feldname]
        when "Verantwortliche Abteilung"
          c.inventory_pool_id == @package.inventory_pool_id
        when "Verantwortliche Person"
          c.responsible == @package.responsible
        when "Gebäude", "Raum", "Gestell"
          c.location_id == @package.location_id
        when "Toni-Ankunftsdatum"
          c.properties[:ankunftsdatum] == @package.properties[:ankunftsdatum]
        when "Letzte Inventur"
          c.last_check == @package.last_check
        else
          "not found"
      end
    }
    expect(b).to be true
  end
end

Then(/^I only see packages which I am responsible for$/) do
  within "#packages" do
    dom_package_items = Item.find(all(".list-of-lines > .line").map{|x| x["data-id"] })
    db_items = @model.items.where(inventory_pool_id: @current_inventory_pool)
    expect(dom_package_items).to eq db_items
  end
end
