# encoding: utf-8

Wenn /^ich mindestens die Pflichtfelder ausfülle$/ do
  @model_name = "Test Modell-Paket"
  find(".row.emboss", match: :prefer_exact, :text => _("Name")).fill_in 'model[name]', :with => @model_name
end

Wenn /^ich eines oder mehrere Pakete hinzufüge$/ do
  find("button", match: :prefer_exact, text: _("Add %s") % _("Package")).click
end

Wenn /^ich(?: kann | )diesem Paket eines oder mehrere Gegenstände hinzufügen$/ do
  find(".modal #search-item").set "beam123"
  find("a", match: :prefer_exact, text: "beam123").click
  find(".modal #search-item").set "beam345"
  find("a", match: :prefer_exact, text: "beam345").click
end

Dann /^ist das Modell erstellt und die Pakete und dessen zugeteilten Gegenstände gespeichert$/ do
  page.should have_selector ".success"
  @model = Model.find_by_name @model_name
  @model.should_not be_nil
  @model.should be_is_package
  @packages = @model.items
  @packages.count.should eq 1
  @packages.first.children.first.inventory_code.should eql "beam123"
  @packages.first.children.second.inventory_code.should eql "beam345"
end

Dann /^den Paketen wird ein Inventarcode zugewiesen$/ do
  @packages.first.inventory_code.should_not be_nil
  sleep 1.22 # fix lazy request problem
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
  Item.find_by_id(@package.id).nil?.should be_true
  lambda {@package.reload}.should raise_error(ActiveRecord::RecordNotFound)
  @package_item_ids.size.should > 0
  @package_item_ids.each{|id| Item.find(id).parent_id.should be_nil}
  sleep(0.99) # fix lazy request problem
end

Wenn /^das Paket zurzeit ausgeliehen ist$/ do
  @package_not_in_stock = @current_inventory_pool.items.packages.not_in_stock.first
  visit manage_edit_model_path(@current_inventory_pool, @package_not_in_stock.model)
end

Dann /^kann ich das Paket nicht löschen$/ do
  page.should_not have_selector("[data-type='inline-entry'][data-id='#{@package_not_in_stock.id}'] [data-remove]")
end

Wenn /^ich ein Modell editiere, welches bereits Pakete hat$/ do
  visit manage_inventory_path(@current_inventory_pool)
  @model = @current_inventory_pool.models.detect {|m| not m.items.empty? and m.is_package?}
  @model_name = @model.name
  step 'ich nach "%s" suche' % @model.name
  page.should have_selector(".line", text: @model.name)
  find(".line", match: :prefer_exact, :text => @model.name).first(".button", :text => _("Edit Model")).click
end

Wenn /^ich ein Modell editiere, welches bereits Gegenstände hat$/ do
  visit manage_inventory_path(@current_inventory_pool)
  @model = @current_inventory_pool.models.detect {|m| not (m.items.empty? and m.is_package?)}
  @model_name = @model.name
  step 'ich nach "%s" suche' % @model.name
  page.should have_selector(".line", text: @model.name)
  find(".line", match: :prefer_exact, :text => @model.name).first(".button", :text => _("Edit Model")).click
end

Dann /^kann ich diesem Modell keine Pakete mehr zuweisen$/ do
  page.should_not have_selector("a", text: _("Add %s") % _("Package"))
end

Wenn /^ich einem Modell ein Paket hinzufüge$/ do
  step "ich ein neues Modell hinzufüge"
  step 'ich mindestens die Pflichtfelder ausfülle'
  step "ich eines oder mehrere Pakete hinzufüge"
end

Dann /^kann ich dieses Paket nur speichern, wenn dem Paket auch Gegenstände zugeteilt sind$/ do
  find("#save-package").click
  page.should have_content _("You can not create a package without any item")
  page.should have_content _("New Package")
  find(".modal-close").click
  page.should_not have_selector("[data-type='field-inline-entry']")
end

Wenn /^ich ein Paket editiere$/ do
  @model = Model.find_by_name "Kamera Set"
  visit manage_edit_model_path(@current_inventory_pool, @model)
  @package_to_edit = @model.items.detect &:in_stock?
  find(".line[data-id='#{@package_to_edit.id}']").find("button[data-edit-package]").click
end

Dann /^kann ich einen Gegenstand aus dem Paket entfernen$/ do
  find(".modal #items [data-type='inline-entry']", match: :first)
  items = all("#items [data-type='inline-entry']")
  @number_of_items_before = items.size
  @item_to_remove = items.first.text
  find("#items [data-remove]", match: :first).click
  find("#save-package").click
  step 'ich speichere die Informationen'
end

Dann /^dieser Gegenstand ist nicht mehr dem Paket zugeteilt$/ do
  page.has_content? _("List of Models")
  @package_to_edit.reload
  @package_to_edit.children.count.should eq (@number_of_items_before - 1)
  @package_to_edit.children.detect {|i| i.inventory_code == @item_to_remove}.should be_nil
  sleep(1.22) # fix lazy request problem
end

Dann /^werden die folgenden Felder angezeigt$/ do |table|
  values = table.raw.map do |x|
    x.first.gsub(/^\-\ |\ \-$/, '')
  end
  (page.text =~ Regexp.new(values.join('.*'), Regexp::MULTILINE)).should_not be_nil
end

Wenn /^ich das Paket speichere$/ do
  find(".modal #save-package", match: :first).click
end

Wenn /^ich das Paket und das Modell speichere$/ do
  step 'ich das Paket speichere'
  find("button#model-save", match: :first).click
end

Dann /^(?:besitzt das Paket alle angegebenen Informationen|das Paket besitzt alle angegebenen Informationen)$/ do
  sleep(0.88)
  model = Model.find_by_name @model_name
  visit manage_edit_model_path(@current_inventory_pool, model)
  model.items.each do |item|
    page.has_selector? ".line[data-id='#{item.id}']", visible: false
  end
  page.has_no_selector? "[src*='loading']"
  find(".line[data-id='#{model.items.first.id}']", visible: false).find("button[data-edit-package]").click
  page.has_selector? ".modal .row.emboss"
  step 'hat das Paket alle zuvor eingetragenen Werte'
end

Wenn /^ich ein bestehendes Paket editiere$/ do
  find("[data-edit-package]", match: :first).click
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
    | Anschaffungswert             |              | 50.0                          |}
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
  page.has_selector? ".modal .row.emboss"
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
end
