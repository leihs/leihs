# -*- encoding : utf-8 -*-

Given /^the availability is loaded$/ do
  within "#status" do
    unless has_content? _("No hand overs found")
      find(".icon-ok")
      find("p", text: _("Availability loaded"))
    end
  end
end


#Angenommen(/^es besteht bereits eine Aushändigung mit mindestens (\d+) zugewiesenen Gegenständen für einen Benutzer$/) do |count|
Given(/^there is a hand over with at least (\d+) assigned items for a user$/) do |count|
  @hand_over = @current_inventory_pool.visits.hand_over.find {|ho| ho.contract_lines.select(&:item).size >= count.to_i}
  expect(@hand_over).not_to be_nil
end

#Wenn(/^ich die Aushändigung öffne$/) do
When(/^I open the hand over$/) do
  visit manage_hand_over_path(@current_inventory_pool, @hand_over.user)
  step "the availability is loaded"
end

#Dann(/^sehe ich all die bereits zugewiesenen Gegenstände mittels Inventarcodes$/) do
Then(/^I see the already assigned items and their inventory codes$/) do
  @hand_over.contract_lines.each do |line|
    next if not line.is_a?(ItemLine) or line.item_id.nil?
    find("[data-assign-item][disabled][value='#{line.item.inventory_code}']")
  end
end


#When(/^der Benutzer für die Aushändigung ist gesperrt$/) do
When(/^the user in this hand over is suspended$/) do
  ensure_suspended_user(@customer, @current_inventory_pool)
  step "I open a hand over to this customer"
end

# Superseded by sign_contract_steps.rb
#Angenommen(/^ich öffne eine Aushändigung( mit einer Software)?$/) do |arg1|
Given(/^I open a hand over containing software$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.order("RAND ()").detect {|v| v.contract_lines.any?{|cl| cl.model.is_a? Software } }
  step "I open the hand over"
end

#Angenommen(/^es gibt eine Aushändigung mit mindestens einem nicht problematischen Modell( und einer Option)?$/) do |arg1|
Given(/^there is a hand over with at least one unproblematic model( and an option)?$/) do |arg1|
  @models_in_stock = @current_inventory_pool.items.in_stock.map(&:model).uniq
  @hand_over = @current_inventory_pool.visits.hand_over.detect do |v|
    b = v.lines.select do |line|
      !line.start_date.past? and !line.item and @models_in_stock.include?(line.model)
    end.count >= 1
    if arg1 and b
      b = (b and v.lines.any? {|line| line.is_a? OptionLine })
    end
    b
  end
  expect(@hand_over).not_to be_nil
end


#Angenommen(/^es gibt eine Aushändigung mit mindestens (einer problematischen Linie|einem Gegenstand ohne zugeteilt Raum und Gestell)$/) do |arg1|
Given(/^there is a hand over with at least (one problematic line|an item without room or shelf)$/) do |arg1|
  @hand_over = @current_inventory_pool.visits.hand_over.find do |ho|
    ho.lines.any? do |l|
      if l.is_a? ItemLine
        case arg1
          when "one problematic line"
            #old#
            # av = l.model.availability_in(@current_inventory_pool).maximum_available_in_period_summed_for_groups(l.start_date, l.end_date, ho.user.group_ids)
            # l.start_date.past? and av > 1
            not l.complete?
          when "an item without room or shelf"
            l.item and (l.item.location.nil? or (l.item.location.room.blank? and l.item.location.shelf.blank?))
          else
            raise
        end
      end
    end
  end
  expect(@hand_over).not_to be_nil
end

#Wenn(/^ich dem nicht problematischen Modell einen Inventarcode zuweise$/) do
When(/^I assign an inventory code to the unproblematic model$/) do
  @contract_line = @hand_over.lines.find {|l| !l.start_date.past? and !l.item and @models_in_stock.include?(l.model) }
  @line_css = ".line[data-id='#{@contract_line.id}']"
  within @line_css do
    find("input[data-assign-item]").click
    find("li.ui-menu-item a", match: :first).click
  end
end

#Dann(/^wird der Gegenstand der Zeile zugeteilt$/) do
Then(/^the item is assigned to the line$/) do
  find("#flash")
  expect(@contract_line.reload.item).not_to be_nil
end


#Dann(/^die Zeile wird selektiert|wird die Zeile selektiert$/) do
Then(/^the line is selected$/) do
  find(@line_css).find("input[type=checkbox]:checked")
end

#Dann(/^die Zeile wird grün markiert|wird die Zeile grün markiert$/) do
Then(/^the line is highlighted in green$/) do
  expect(find(@line_css).native.attribute("class")).to include "green"
end


#Wenn(/^ich die Zeile deselektiere$/) do
When(/^I deselect the line$/) do
  within @line_css do
    find("input[type=checkbox]").click
    expect(find("input[type=checkbox]").checked?).to be false
  end
end

#Dann(/^ist die Zeile nicht mehr grün eingefärbt$/) do
Then(/^the line is no longer highlighted in green$/) do
  expect(find(@line_css).native.attribute("class")).not_to include "green"
end

#Wenn(/^ich die Zeile wieder selektiere$/) do
When(/^I reselect the line$/) do
  within @line_css do
    find("input[type=checkbox]").click
    find("input[type=checkbox]:checked")
  end
end

#Wenn(/^ich den zugeteilten Gegenstand auf der Zeile entferne$/) do
When(/^I remove the assigned item from the line$/) do
  find(@line_css).find(".icon-remove-sign").click
end

#Dann(/^wird das Problemfeld für das problematische Modell angezeigt$/) do
Then(/^problem notifications are shown for the problematic model$/) do
  @contract_line = @hand_over.lines.find do |l|
    if l.is_a? ItemLine
      #old#
      # av = l.model.availability_in(@current_inventory_pool).maximum_available_in_period_summed_for_groups(l.start_date, l.end_date, @hand_over.user.group_ids)
      # l.start_date.past? and av > 1
      not l.complete?
    end
  end
  @line_css = ".line[data-id='#{@contract_line.id}']"
  step "the problem notifications remain on the line"
end

#Wenn(/^ich dieser Linie einen Inventarcode manuell zuweise$/) do
When(/^I manually assign an inventory code to that line$/) do
  within @line_css do
    find("input[data-assign-item]").click
    find("li.ui-menu-item a", match: :first).click
  end
end

#Dann(/^die problematischen Auszeichnungen bleiben bei der Linie bestehen$/) do
Then(/^the problem notifications remain on the line$/) do
  within @line_css do
    expect(has_selector?(".line-info.red")).to be true
    expect(has_selector?(".tooltip.red")).to be true
  end
end

#Wenn(/^ich einen bereits hinzugefügten Gegenstand zuteile$/) do
When(/^I assign an already added item$/) do
  @contract_line = @hand_over.lines.find {|l| l.is_a? ItemLine and l.item}
  @line_css = ".line[data-id='#{@contract_line.id}']"
  find(@line_css).find("input[type='checkbox']").click

  find("input#assign-or-add-input").set @contract_line.item.inventory_code
  find("form#assign-or-add button .icon-plus-sign-alt", match: :first).click
end



#Dann(/^erhalte ich eine entsprechende Info\-Meldung 'XY ist bereits diesem Vertrag zugewiesen'$/) do
Then(/^I see the error message 'XY is already assigned to this contract'$/) do
  find "#flash", text: _("%s is already assigned to this contract") % @contract_line.item.inventory_code
end


#Angenommen(/^ich öffne eine Aushändigung mit mindestens einem zugewiesenen Gegenstand$/) do
Given(/^I open a hand over with at least one assigned item$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.find {|ho| ho.lines.any? &:item_id}
  step "I open the hand over"
end

#Dann(/^die Zeile bleibt selektiert$/) do
Then(/^the line remains selected$/) do
  expect(has_selector?("#{@line_css} input[type='checkbox']:checked")).to be true
end

#Dann(/^die Zeile bleibt grün markiert$/) do
Then(/^the line remains highlighted in green$/) do
  expect(has_selector?("#{@line_css}.green")).to be true
end


#Angenommen(/^für den Gerätepark ist eine Standard\-Vertragsnotiz konfiguriert$/) do
Given(/^there is a default contract note for the inventory pool$/) do
  expect(@current_inventory_pool.default_contract_note).not_to be_nil
end


#Dann(/^erscheint ein Aushändigungsdialog$/) do
Then(/^a hand over dialog appears$/) do
  expect(has_selector?(".modal [data-hand-over]")).to be true
end

Then(/^a dialog appears$/) do
  expect(has_selector?(".modal")).to be true
end


#Dann(/^diese Standard\-Vertragsnotiz erscheint im Textfeld für die Vertragsnotiz$/) do
Then(/^the contract note field in this dialog is already filled in with the default note$/) do
  find("textarea[name='note']", text: @current_inventory_pool.default_contract_note)
end

Then(/^I can enter some text in the contract note field$/) do
  find("textarea[name='note']")
end

When(/^I enter "(.*?)" in the contract note field$/) do |string|
  field = find("textarea[name='note']")
  fill_in field[:id], :with => string
end


When(/^I change the quantity to "(.*?)"$/) do |arg1|
  within @line_css do
    find("input[data-line-quantity]").set arg1
    sleep(0.66) # NOTE this sleep is required in order to fire the change
  end
end

Then(/^the quantity will be restored to the original value$/) do
  within @line_css do
    find("input[data-line-quantity][value='#{@option_line.reload.quantity}']")
  end
end

Then(/^the quantity will be stored to the value "(.*?)"$/) do |arg1|
  step "the quantity will be restored to the original value"
  expect(@option_line.quantity.to_s).to eq arg1
end

Given(/^a line has no item assigned yet and this line is marked$/) do
  step "I can add models"
  @contract_line = @hand_over.lines.order(created_at: :desc).first
  @line_css = ".line[data-id='#{@contract_line.id}']"
end

Given(/^a line with an assigned item which doesn't have a location is marked$/) do
  @contract_line = @hand_over.lines.where(type: "ItemLine").find {|l| l.item and (l.item.location.nil? or (l.item.location.room.blank? and l.item.location.shelf.blank?)) }
  @line_css = ".line[data-id='#{@contract_line.id}']"
  step "ich die Zeile wieder selektiere"
end

Given(/^an option line is marked$/) do
  @contract_line = @hand_over.lines.where(type: "OptionLine").order("RAND()").first
  @line_css = ".line[data-id='#{@contract_line.id}']"
  step "ich die Zeile wieder selektiere"
end

When(/^I select at least one line$/) do
  @line_css = all(".line[data-id]").to_a.sample
  step "ich die Zeile wieder selektiere"
end

Given(/^there is a model with a problematic item$/) do
  @item = @current_inventory_pool.items.borrowable.in_stock.find {|item| item.is_broken? or item.is_incomplete?}
  expect(@item).not_to be_nil
  @model = @item.model
  expect(@model).not_to be_nil
end

Then(/^"(.*?)" appears on the contract$/) do |string|
  new_window = page.driver.browser.window_handles.last
  page.driver.browser.switch_to.window new_window
  contract_element = find(".contract")
  note_field = contract_element.find("section.note")
  expect(note_field.text.match(/#{string}/)).not_to be_nil
end

When(/^I open the item choice list on the model line$/) do
  within "#lines" do
    find("[data-line-type]", text: @model.name).find("[data-assign-item]").click
    expect(has_selector?(".ui-menu")).to be true
  end
end

Then(/^the problematic item is displayed red$/) do
  find(".ui-menu .ui-menu-item .light-red", text: @item.inventory_code)
end

Given(/^there is a model with a retired and a borrowable item$/) do
  @model = @current_inventory_pool.models.find { |m| m.items.borrowable.where(retired: nil).exists? and m.items.retired.exists? }
  expect(@model).not_to be_nil
  @item = @model.items.retired.order("RAND()").first
end

Then(/^the retired item is not displayed in the list$/) do
  expect(page).not_to have_selector(".ui-menu .ui-menu-item", text: @item.inventory_code)
end
