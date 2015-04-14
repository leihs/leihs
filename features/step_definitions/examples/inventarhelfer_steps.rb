# encoding: utf-8

#Dann /^kann man über die Tabnavigation zum Helferschirm wechseln$/ do
Then(/^I see a tab where I can change to the inventory helper$/) do
  find("#inventory-index-view nav a.navigation-tab-item", :text => _("Helper")).click
  find("h1", :text => _("Inventory Helper"))
end

#Angenommen /^man ist auf dem Helferschirm$/ do
Given /^I am on the inventory helper screen$/ do
  visit manage_inventory_helper_path @current_inventory_pool
end

#Dann /^wähle ich all die Felder über eine List oder per Namen aus$/ do
Then /^I choose all fields through a list or by name$/ do
  i = find("#inventory-helper-view #field-input")
  while(i.click and page.has_selector?(".ui-menu-item a", visible: true)) do
    find(".ui-menu-item a", match: :first, :visible => true).click
  end
end

#Dann /^ich setze all ihre Initalisierungswerte$/ do
Then /^I set all their initial values$/ do
  @parent_el ||= find("#field-selection")
  @data = {}
  Field.all.each do |field|
    next if @parent_el.all(".field[data-id='#{field[:id]}']").empty?
    field_el = @parent_el.find(".field[data-id='#{field[:id]}']")
    case field[:type]
      when "radio"
        r = field_el.find("input[type=radio]", match: :first)
        r.click
        @data[field[:id]] = r.value
      when "textarea"
        ta = field_el.find("textarea")
        ta.set "This is a text for a textarea"
        @data[field[:id]] = ta.value
      when "select"
        o = field_el.find("option", match: :first)
        o.select_option
        @data[field[:id]] = o.value
      when "text"
        within field_el do
          string = if all("input[name='item[inventory_code]']").empty?
                     "This is a text for a input text"
                   else
                     "123456"
                   end
          i = find("input[type='text']")
          i.set string
          @data[field[:id]] = i.value
        end
      when "date"
        dp = field_el.find("[data-type='datepicker']")
        dp.click
        find(".ui-datepicker-calendar").find(".ui-state-highlight, .ui-state-active", visible: true, match: :first).click
        @data[field[:id]] = dp.value
      when "autocomplete"
        target_name = find(".field[data-id='#{field[:id]}'] [data-type='autocomplete']")['data-autocomplete_value_target']
        find(".field[data-id='#{field[:id]}'] [data-type='autocomplete'][data-autocomplete_value_target='#{target_name}']").click
              find(".ui-menu-item a", match: :first).click
        @data[field[:id]] = find(".field[data-id='#{field[:id]}'] [data-type='autocomplete']")
      when "autocomplete-search"
        model = if @item and @item.children.exists? # item is a package
                  Model.all.find &:is_package?
                else
                  Model.all.find {|m| not m.is_package?}
                end
        string = model.name
        within ".field[data-id='#{field[:id]}']" do
          find("input").click
          find("input").set string
        end
        find(".ui-menu-item a", match: :prefer_exact, text: string).click
        @data[field[:id]] = Model.find_by_name(string).id
      when "checkbox"
        # currently we only have "ausgemustert"
        field_el.find("input[type='checkbox']").click
        find("[name='item[retired_reason]']").set "This is a text for a input text"
        @data[field[:id]] = "This is a text for a input text"
      else
        raise "field type not found"
    end
  end
end

#Dann /^ich setze das Feld "(.*?)" auf "(.*?)"$/ do |field_name, value|
Then /^I set the field "(.*?)" to "(.*?)"$/ do |field_name, value|
  field = Field.find find(".row.emboss[data-type='field']", match: :prefer_exact, text: field_name)["data-id"]
  within(".field[data-id='#{field[:id]}']") do
    case field[:type]
      when "radio"
        find("label", :text => value).click
      when "select"
        find("option", :text => value).select_option
      when "checkbox"
        find("label", :text => value).click
      else
        raise "unknown field"
    end
  end
end

#Dann /^scanne oder gebe ich den Inventarcode von einem Gegenstand ein, der am Lager und in keinem Vertrag vorhanden ist$/ do
Then /^I scan or enter the inventory code of an item that is in stock and not in any contract$/ do
  @item = @current_inventory_pool.items.in_stock.order("RAND()").first
  within("#item-selection") do
    find("[data-barcode-scanner-target]").set @item.inventory_code
    find("button[type=submit]").click
  end
end


#Dann /^scanne oder gebe ich den Inventarcode ein(, wo man Besitzer ist)$/ do |arg1|
Then /^I scan or enter the inventory code( of an item belonging to the current inventory pool)?$/ do |arg1|
  @item ||= if arg1
              @current_inventory_pool.items.where(owner_id: @current_inventory_pool)
            else
              @current_inventory_pool.items
            end.in_stock.order("RAND()").first
  within("#item-selection") do
    find("[data-barcode-scanner-target]").set @item.inventory_code
    find("button[type=submit]").click
  end
end

#Dann /^sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert$/ do
Then /^I see all the values of the item in an overview with model name and the modified values are already saved$/ do
  FastGettext.locale = @current_user.language.locale_name.gsub(/-/, "_")
  Field.all.each do |field|
    next if all(".field[data-id='#{field[:id]}']").empty?
    within("form#flexible-fields") do
      field_el = find(".field[data-id='#{field.id}']")
      value = field.get_value_from_params @item.reload
      field_type = field.type
      if field_type == "date"
        unless value.blank?
          value = Date.parse(value) if value.is_a?(String)
          field_el.has_content? value.year
          field_el.has_content? value.month
          field_el.has_content? value.day
        end
      elsif field[:attribute] == "retired"
        unless value.blank?
          field_el.has_content? _(field[:values].first[:label])
        end
      elsif field_type == "radio"
        if value
          value = field[:values].detect{|v| v[:value] == value}[:label]
          field_el.has_content? _(value)
        end
      elsif field_type == "select"
        if value
          value = field[:values].detect{|v| v[:value] == value}[:label]
          field_el.has_content? _(value)
        end
      elsif field_type == "autocomplete"
        if value
          value = field.as_json["values"].detect{|v| v["value"] == value}["label"]
          field_el.has_content? _(value)
        end
      elsif field_type == "autocomplete-search"
        if value
          if field[:label] == "Model"
            value = Model.find(value).name
            field_el.has_content? value
          end
        end
      else
        field_el.has_content? _(value)
      end
    end
  end

  find("form#flexible-fields .field[data-id='#{Field.find_by_label("Model").id}']", text: @item.reload.model.name)
end

#Dann /^die geänderten Werte sind hervorgehoben$/ do
Then /^the changed values are highlighted$/ do
  find("#field-selection .field", match: :first)
  all("#field-selection .field").each do |selected_field|
    c = all("#item-section .field[data-id='#{selected_field['data-id']}'].success").count + all("#item-section .field[data-id='#{selected_field['data-id']}'].error").count
    expect(c).to eq 1
  end
end

#Dann /^wähle ich die Felder über eine List oder per Namen aus$/ do
Then /^I choose the fields from a list or by name$/ do
  field = Field.all.select{|f| f[:readonly] == nil and f[:type] != "autocomplete-search" and f[:target_type] != "license" and not f[:visibility_dependency_field_id]}.last
  find("#field-input").click
  find("#field-input").set _(field.label)
  find(".ui-menu-item a", match: :first, text: _(field.label)).click
  within "#field-selection" do
    @all_editable_fields = all(".field", :visible => true)
  end
end

#Dann /^ich setze ihre Initalisierungswerte$/ do
Then /^I set their initial values$/ do
  within "#field-selection" do
    fields = all(".field input, #field-selection .field textarea", :visible => true)
    expect(fields.count).to be > 0
    fields.each do |input|
      input.set "Test123"
    end
  end
end

#Dann /^scanne oder gebe ich den Inventarcode eines Gegenstandes ein der nicht gefunden wird$/ do
Then /^I scan or enter the inventory code of an item that can't be found$/ do
  @not_existing_inventory_code = "THIS FOR SURE NO INVENTORY CODE"
  within("#item-selection") do
    find("[data-barcode-scanner-target]").set @not_existing_inventory_code
    find("button[type=submit]").click
  end
end

#Dann /^gebe ich den Anfang des Inventarcodes eines Gegenstand ein$/ do
Then /^I start entering an item's inventory code$/ do
  @item= @current_inventory_pool.items.first
  find("#item-selection [data-barcode-scanner-target]").set @item.inventory_code[0..1]
end


#Dann /^wähle den Gegenstand über die mir vorgeschlagenen Suchtreffer$/ do
Then /^I choose the item from the list of results$/ do
  expect(has_selector?(".ui-menu-item")).to be true
  # This sometimes finds multiple results. How is that even possible?
  find(".ui-menu-item a", :text => @item.inventory_code).click
end

#Angenommen /^man editiert ein Gerät über den Helferschirm mittels Inventarcode$/ do
Given /^I edit an item through the inventory helper using an inventory code$/ do
  step 'I am on the inventory helper screen'
  step 'I choose the fields from a list or by name'
  step 'I set their initial values'
  step 'scanne oder gebe ich den Inventarcode ein, wo man Besitzer ist'
  step 'I see all the values of the item in an overview with model name and the modified values are already saved'
  step 'the changed values are highlighted'
end

#Wenn /^man die Editierfunktion nutzt$/ do
When /^I use the edit feature$/ do
  find("#item-section button#item-edit", :text => _("Edit Item")).click
end

#Dann /^kann man an Ort und Stelle alle Werte des Gegenstandes editieren$/ do
Then /^I can edit all of this item's values right then and there$/ do
  @parent_el = find("#item-section")
  step 'I set their initial values'
end

#Dann /^sind sie gespeichert$/ do
Then /^my changes are saved$/ do
  step %Q{I see all the values of the item in an overview with model name and the modified values are already saved}
end

#Wenn /^man seine Änderungen widerruft$/ do
When /^I cancel$/ do
  find("#item-section a", :text => _("Cancel")).click
end

#Dann /^sind die Änderungen widerrufen$/ do
Then /^the changes are reverted$/ do
  expect(@item.to_json).to eq @item.reload.to_json
end

# Use the step inside directly, not this one
#Dann /^man sieht alle ursprünglichen Werte des Gegenstandes in der Übersicht$/ do
#  step %Q{I see all the values of the item in an overview with model name and the modified values are already saved}
#end

Then(/^I select the field "(.*?)"$/) do |field|
  find("#field-input").click
  find("#field-input").set field
  find(".ui-menu-item a", match: :prefer_exact, text: field).click
  within "#field-selection" do
    @all_editable_fields = all(".field", :visible => true)
  end
end

Then(/^I set some value for the field "(.*?)"$/) do |field|
  find(".row.emboss", match: :prefer_exact, text: field).find("input").set "Test123"
end

#Angenommen(/^es existiert ein Gegenstand, welches sich denselben Ort mit einem anderen Gegenstand teilt$/) do
Given(/^there is an item that shares its location with another$/) do
  location = Location.find {|l| l.items.where(inventory_pool_id: @current_inventory_pool, parent_id: nil).count >= 2}
  @item, @item_2 = location.items.where(inventory_pool_id: @current_inventory_pool, parent_id: nil).order("RAND()").limit(2)
  @item_2_location = @item_2.location
end

#Dann(/^gebe ich den Anfang des Inventarcodes des spezifischen Gegenstandes ein$/) do
Then(/^I enter the start of the inventory code of the specific item$/) do
  find("#item-selection [data-barcode-scanner-target]").set @item.inventory_code[0..1]
end

#Dann(/^der Ort des anderen Gegenstandes ist dergleiche geblieben$/) do
Then(/^the location of the other item has remained the same$/) do
  expect(@item_2.reload.location).to eq @item_2_location
end

#Wenn(/^"(.*?)" ausgewählt und auf "(.*?)" gesetzt wird, dann muss auch "(.*?)" angegeben werden$/) do |field, value, dependent_field|
When(/^"(.*?)" is selected and set to "(.*?)", then "(.*?)" must also be filled in$/) do |field, value, dependent_field|
  find("#field-input").click
  find("#field-input").set field
  find(".ui-menu-item a", match: :prefer_exact, text: field).click
  step 'I set the field "%s" to "%s"' % [field, value]
  find(".row.emboss", match: :prefer_exact, text: dependent_field)
end

#Wenn(/^ein Pflichtfeld nicht ausgefüllt\/ausgewählt ist, dann lässt sich der Inventarhelfer nicht nutzen$/) do
When(/^a required field is blank, the inventory helper cannot be used$/) do
  step %Q{I scan or enter the inventory code}
end

#Angenommen(/^man editiert das Feld "(.*?)" eines ausgeliehenen Gegenstandes$/) do |name|
Given(/^I edit the field "(.*?)" of an item that is not in stock$/) do |name|
  step %Q{I select the field "#{name}"}
  @item = @current_inventory_pool.items.not_in_stock.order("RAND()").first
  @item_before = @item.to_json
  step %Q{I scan or enter the inventory code}
end

#Dann(/^erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät ausgeliehen ist$/) do
Then(/^I see an error message that I can't change the responsible inventory pool for items that are not in stock$/) do
  expect(page.has_content?(
      _("The responsible inventory pool cannot be changed because it's not returned yet or has already been assigned to a contract line."))
  ).to be true
  expect(@item_before).to eq @item.reload.to_json
end

#Dann(/^erhält man eine Fehlermeldung, dass man den Gegenstand nicht ausmustern kann, da das Gerät bereits ausgeliehen oder einer Vertragslinie zugewiesen ist$/) do
Then(/^I see an error message that I can't retire the item because it's already handed over or assigned to a contract$/) do
  expect(has_content?(_("The item cannot be retired because it's not returned yet or has already been assigned to a contract line."))).to be true
  expect(@item_before).to eq @item.reload.to_json
end

#Dann(/^erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät in einem Vortrag vorhanden ist$/) do
Then(/^I see an error message that I can't change the model because the item is already handed over or assigned to a contract$/) do
  expect(has_content?(_("The model cannot be changed because the item is used in contracts already."))).to be true
  expect(@item_before).to eq @item.reload.to_json
end

#Angenommen(/^man editiert das Feld "(.*?)" eines Gegenstandes, der im irgendeinen Vertrag vorhanden ist$/) do |name|
Given(/^I edit the field "(.*?)" of an item that is part of a contract$/) do |name|
  step %Q{I select the field "#{name}"}
  @item = @current_inventory_pool.items.not_in_stock.order("RAND()").first
  @item_before = @item.to_json
  fill_in_autocomplete_field name, @current_inventory_pool.models.order("RAND()").detect {|m| m != @item.model}.name
  step %Q{I scan or enter the inventory code}
end

#Angenommen(/^man mustert einen ausgeliehenen Gegenstand aus$/) do
Given(/^I retire an item that is not in stock$/) do
  step %Q{I select the field "Retiremen"}
  find(".row.emboss", match: :prefer_exact, text: _("Retirement")).find("select").select _("Yes")
  find(".row.emboss", match: :prefer_exact, text: _("Reason for Retirement")).find("input, textarea").set "Retirement reason"
  @item = @current_inventory_pool.items.where(owner: @current_inventory_pool).not_in_stock.order("RAND()").first
  @item_before = @item.to_json
  step %Q{I scan or enter the inventory code}
end

Given(/^I edit the field "Responsible department" of an item that isn't in stock and belongs to the current inventory pool$/) do
  step %Q{I select the field "Responsible department"}
  @item = @current_inventory_pool.items.where(owner: @current_inventory_pool).not_in_stock.order("RAND()").first
  @item_before = @item.to_json
  fill_in_autocomplete_field "Responsible department", InventoryPool.where.not(id: @current_inventory_pool).order("RAND()").first.name
  step %Q{I scan or enter the inventory code}
end
