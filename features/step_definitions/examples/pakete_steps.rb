# encoding: utf-8

#Wenn /^ich mindestens die Pflichtfelder ausfülle$/ do
When /^I fill in at least the required fields$/ do
  @model_name = "Test Model Package"
  find(".row.emboss", match: :prefer_exact, :text => _("Product")).fill_in 'model[product]', :with => @model_name
end

#Wenn /^ich eines oder mehrere Pakete hinzufüge$/ do
When /^I add one or more packages$/ do
  find("button", match: :prefer_exact, text: _("Add %s") % _("Package")).click
end

#Wenn /^ich(?: kann | )diesem Paket eines oder mehrere Gegenstände hinzufügen$/ do
When /^I add one or more items to this package$/ do
  within ".modal" do
    find("#search-item").set "beam123"
    find("a", match: :prefer_exact, text: "beam123").click
    find("#search-item").set "beam345"
    find("a", match: :prefer_exact, text: "beam345").click

    # check that the retired items are excluded from autocomplete search. pivotal bug 69161270
    find("#search-item").set "Bose"
    find("a", match: :prefer_exact, text: "Bose").click
  end
end

#Dann /^ist das Modell erstellt und die Pakete und dessen zugeteilten Gegenstände gespeichert$/ do
Then /^the model is created and the packages and their assigned items are saved$/ do
  expect(has_selector?(".success")).to be true
  @model = Model.find {|m| [m.name, m.product].include? @model_name}
  expect(@model.nil?).to be false
  expect(@model.is_package?).to be true
  @packages = @model.items
  expect(@packages.count).to eq 1
  expect(@packages.first.children.first.inventory_code).to eq "beam123"
  expect(@packages.first.children.second.inventory_code).to eq "beam345"
end

#Dann /^den Paketen wird ein Inventarcode zugewiesen$/ do
Then /^the packages have their own inventory codes$/ do
  expect(@packages.first.inventory_code).not_to be_nil
end

Given /^a (never|once) handed over item package is currently in stock$/ do |arg1|
  item_packages = @current_inventory_pool.items.packages.in_stock.order("RAND ()")
  @package = case arg1
               when "never"
                 item_packages.detect {|p| p.item_lines.empty? }
               when "once"
                 item_packages.detect {|p| p.item_lines.exists? }
             end
end

When(/^edit the related model package$/) do
  visit manage_edit_model_path(@current_inventory_pool, @package.model)
end

When(/^I delete that item package$/) do
  @package_item_ids = @package.children.map(&:id)
  find("[data-type='inline-entry'][data-id='#{@package.id}'] [data-remove]").click
  #step 'ich speichere die Informationen'
  step 'I save'
  find("#flash")
end

Then(/^the item package has been (deleted|retired)$/) do |arg1|
  case arg1
    when "deleted"
      expect(Item.find_by_id(@package.id).nil?).to be true
      expect { @package.reload }.to raise_error(ActiveRecord::RecordNotFound)
    when "retired"
      expect(Item.find_by_id(@package.id).nil?).to be false
      expect(@package.reload.retired).to eq Date.today
  end
end

Then /^the packaged items are not part of that item package anymore$/ do
  expect(@package_item_ids.size).to be > 0
  @package_item_ids.each do |id|
    expect(Item.find(id).parent_id).to eq nil
  end
end

Then(/^that item package is not listed$/) do
  expect(has_no_selector? "[data-type='inline-entry'][data-id='#{@package.id}']").to be true
end

#Wenn /^das Paket zurzeit ausgeliehen ist$/ do
When /^the package is currently not in stock$/ do
  @package_not_in_stock = @current_inventory_pool.items.packages.not_in_stock.order("RAND()").first
  visit manage_edit_model_path(@current_inventory_pool, @package_not_in_stock.model)
end

#Dann /^kann ich das Paket nicht löschen$/ do
Then /^I can't delete the package$/ do
  expect(has_no_selector?("[data-type='inline-entry'][data-id='#{@package_not_in_stock.id}'] [data-remove]")).to be true
end

#Wenn /^ich ein Modell editiere, welches bereits Pakete( in meine und andere Gerätepark)? hat$/ do |arg1|
When /^I edit a model that already has packages( in mine and other inventory pools)?$/ do |arg1|
  step "I open the inventory"
  @model = @current_inventory_pool.models.order("RAND ()").detect do |m|
    b = (not m.items.empty? and m.is_package?)
    if arg1
      b = (b and m.items.map(&:inventory_pool_id).uniq.size > 1)
    end
    b
  end
  expect(@model).not_to be_nil
  @model_name = @model.name
  step 'I search for "%s"' % @model.name
  expect(has_selector?(".line", text: @model.name)).to be true
  find(".line", match: :prefer_exact, :text => @model.name).find(".button", match: :first, :text => _("Edit Model")).click
end

#Wenn /^ich ein Modell editiere, welches bereits Gegenstände hat$/ do
When /^I edit a model that already has items$/ do
  step "I open the inventory"
  @model = @current_inventory_pool.models.detect {|m| not (m.items.empty? and m.is_package?)}
  @model_name = @model.name
  step 'I search for "%s"' % @model.name
  expect(has_selector?(".line", text: @model.name)).to be true
  find(".line", match: :prefer_exact, :text => @model.name).find(".button", match: :first, :text => _("Edit Model")).click
end

#Dann /^kann ich diesem Modell keine Pakete mehr zuweisen$/ do
Then /^I cannot assign packages to that model$/ do
  expect(has_no_selector?("a", text: _("Add %s") % _("Package"))).to be true
end

#Wenn /^ich einem Modell ein Paket hinzufüge$/ do
When /^I add a package to a model$/ do
  step "I add a new Model"
  step 'I fill in at least the required fields'
  step "I add one or more packages"
end

#Dann /^kann ich dieses Paket nur speichern, wenn dem Paket auch Gegenstände zugeteilt sind$/ do
Then /^I can only save this package if I also assign items$/ do
  find("#save-package").click
  expect(has_content?(_("You can not create a package without any item"))).to be true
  expect(has_content?(_("New Package"))).to be true
  find(".modal-close").click
  expect(has_no_selector?("[data-type='field-inline-entry']")).to be true
end

#Wenn /^ich ein Paket editiere$/ do
When /^I edit a package$/ do
  @model = Model.find {|m| [m.name, m.product].include?"Kamera Set" }
  visit manage_edit_model_path(@current_inventory_pool, @model)
  @package_to_edit = @model.items.detect &:in_stock?
  find(".line[data-id='#{@package_to_edit.id}']").find("button[data-edit-package]").click
end

#Dann /^kann ich einen Gegenstand aus dem Paket entfernen$/ do
Then /^I can remove items from the package$/ do
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
  step 'I save'
end

#Dann /^dieser Gegenstand ist nicht mehr dem Paket zugeteilt$/ do
Then /^those items are no longer assigned to the package$/ do
  expect(has_content?(_("List of Inventory"))).to be true
  @package_to_edit.reload
  expect(@package_to_edit.children.count).to eq (@number_of_items_before - 1)
  expect(@package_to_edit.children.detect {|i| i.inventory_code == @item_to_remove}).to eq nil
end

# Dann /^werden die folgenden Felder angezeigt$/ do |table|
#   values = table.raw.map do |x|
#     x.first.gsub(/^\-\ |\ \-$/, '')
#   end
#   expect(page.text).to match Regexp.new(values.join('.*'), Regexp::MULTILINE)
# end

When /^I save the package$/ do
  find(".modal #save-package", match: :first).click
end

#Wenn /^ich das Paket und das Modell speichere$/ do
When /^I save both package and model$/ do
  step 'I save the package'
  find("button#save", match: :first).click
end

#Dann /^besitzt das Paket alle angegebenen Informationen$/ do
Then /^the package has all the entered information$/ do
  model = Model.find {|m| [m.name, m.product].include? @model_name}
  visit manage_edit_model_path(@current_inventory_pool, model)
  model.items.where(inventory_pool: @current_inventory_pool).each do |item|
    expect(has_selector?(".line[data-id='#{item.id}']", visible: false)).to be true
  end
  expect(has_no_selector?("[src*='loading']")).to be true
  @package ||= model.items.packages.first
  find(".line[data-id='#{@package.id}']").find("button[data-edit-package]").click
  expect(has_selector?(".modal .row.emboss")).to be true
  #step 'hat das Paket alle zuvor eingetragenen Werte'
  step 'the package has all the previously entered values'
end

#Wenn /^ich ein bestehendes Paket editiere$/ do
#When /^I edit an existing package$/ do
# Superseded by: When I edit an existing .*

#Wenn(/^ich eine Paket hinzufüge$/) do
When(/^I add a package$/) do
  find("#add-package").click
  within ".modal" do
    find("[data-type='field']", match: :first)
  end
end

#Wenn(/^ich die Paketeigenschaften eintrage$/) do
When(/^I enter the package properties$/) do
  steps %Q{And I enter the following item information
    | field                  | type         | value           |
    | Working order          | radio        | OK              |
    | Completeness           | radio        | OK              |
    | Borrowable             | radio        | OK              |
    | Relevant for inventory | select       | Yes             |
    | Last Checked           |              | 01/01/2013      |
    | Responsible department | autocomplete | A-Ausleihe      |
    | Responsible person     |              | Matus Kmit      |
    | User/Typical usage     |              | Test Verwendung |
    | Name                   |              | Test Name       |
    | Note                   |              | Test Notiz      |
    | Building               | autocomplete | None            |
    | Room                   |              | Test Raum       |
    | Shelf                  |              | Test Gestell    |
    | Initial Price          |              | 50.00           | }
end

#Wenn(/^ich dieses Paket speichere$/) do
When(/^I save this package$/) do
  find("#save-package").click
end

# Wenn(/^ich dieses Paket wieder editiere$/) do
#   step 'ich ein bestehendes Paket editiere'
# end

#Dann(/^sehe ich die Meldung "(.*?)"$/) do |text|
Then(/^I see the notice "(.*?)"$/) do |text|
  find("#flash", match: :prefer_exact, :text => text)
end

#Dann /^hat das Paket alle zuvor eingetragenen Werte$/ do
Then /^the package has all the previously entered values$/ do
  expect(has_selector?(".modal .row.emboss")).to be true
  @table_hashes.each do |hash_row|
    field_name = hash_row["field"]
    field_value = hash_row["value"]
    field_type = hash_row["type"]
    field = Field.all.detect{|f| _(f.label) == field_name}
    within ".modal" do
      find("[data-type='field'][data-id='#{field.id}']", match: :first)
      matched_field = all("[data-type='field'][data-id='#{field.id}']").last
      expect(matched_field).not_to be_blank
      case field_type
        when "autocomplete"
          expect(matched_field.find("input,textarea").value).to eq (field_value != "None" ? field_value : "")
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
      case t[:field]
        when "Responsible department"
          c.inventory_pool_id == @package.inventory_pool_id
        when "Responsible person"
          c.responsible == @package.responsible
        when "Building", "Room", "Shelf"
          c.location_id == @package.location_id
        when "Check-in Date"
          c.properties[:ankunftsdatum] == @package.properties[:ankunftsdatum]
        when "Last Checked"
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
