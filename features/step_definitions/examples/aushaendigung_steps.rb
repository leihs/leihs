# -*- encoding : utf-8 -*-

Angenommen(/^es besteht bereits eine Aushändigung mit mindestens (\d+) zugewiesenen Gegenständen für einen Benutzer$/) do |count|
  @hand_over = @current_inventory_pool.visits.hand_over.find {|ho| ho.contract_lines.select(&:item).size >= count.to_i}
  expect(@hand_over).not_to be nil
end

Wenn(/^ich die Aushändigung öffne$/) do
  visit manage_hand_over_path(@current_inventory_pool, @hand_over.user)
end

Dann(/^sehe ich all die bereits zugewiesenen Gegenstände mittels Inventarcodes$/) do
  @hand_over.contract_lines.each {|l| find("[data-assign-item][disabled][value='#{l.item.inventory_code}']") }
end

When(/^der Benutzer für die Aushändigung ist gesperrt$/) do
  ensure_suspended_user(@customer, @current_inventory_pool)
  visit manage_hand_over_path(@current_inventory_pool, @customer)
end

Angenommen(/^ich öffne eine Aushändigung( mit einer Software)?$/) do |arg1|
  @hand_over = if arg1
                 @current_inventory_pool.visits.hand_over.shuffle.detect {|v| v.contract_lines.any?{|cl| cl.model.is_a? Software } }
               else
                 @current_inventory_pool.visits.hand_over.sample
               end
  step "ich die Aushändigung öffne"
end

Angenommen(/^es gibt eine Aushändigung mit mindestens einem nicht problematischen Modell( und einer Option)?$/) do |arg1|
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
  expect(@hand_over).not_to be nil
end

Angenommen(/^es gibt eine Aushändigung mit mindestens (einer problematischen Linie|einem Gegenstand ohne zugeteilt Raum und Gestell)$/) do |arg1|
  @hand_over = @current_inventory_pool.visits.hand_over.find do |ho|
    ho.lines.any? do |l|
      if l.is_a? ItemLine
        case arg1
          when "einer problematischen Linie"
            av = l.model.availability_in(@current_inventory_pool).maximum_available_in_period_summed_for_groups(l.start_date, l.end_date, ho.user.groups)
            l.start_date.past? and av > 1
          when "einem Gegenstand ohne zugeteilt Raum und Gestell"
            l.item and (l.item.location.nil? or (l.item.location.room.blank? and l.item.location.shelf.blank?))
          else
            raise "not found"
        end
      end
    end
  end
  expect(@hand_over).not_to be nil
end

Wenn(/^ich dem nicht problematischen Modell einen Inventarcode zuweise$/) do
  @contract_line = @hand_over.lines.find {|l| !l.start_date.past? and !l.item and @models_in_stock.include?(l.model) }
  @line_css = ".line[data-id='#{@contract_line.id}']"
  within @line_css do
    find("input[data-assign-item]").click
    find("li.ui-menu-item a", match: :first).click
  end
end

Dann(/^wird der Gegenstand der Zeile zugeteilt$/) do
  find("#flash")
  expect(@contract_line.reload.item).not_to be nil
end

Dann(/^die Zeile wird selektiert|wird die Zeile selektiert$/) do
  find(@line_css).find("input[type=checkbox]:checked")
end

Dann(/^die Zeile wird grün markiert|wird die Zeile grün markiert$/) do
  expect(find(@line_css).native.attribute("class")).to include "green"
end

Wenn(/^ich die Zeile deselektiere$/) do
  within @line_css do
    find("input[type=checkbox]").click
    expect(find("input[type=checkbox]").checked?).to be false
  end
end

Dann(/^ist die Zeile nicht mehr grün eingefärbt$/) do
  find(@line_css).native.attribute("class").should_not include "green"
end

Wenn(/^ich die Zeile wieder selektiere$/) do
  within @line_css do
    find("input[type=checkbox]").click
    find("input[type=checkbox]:checked")
  end
end

Wenn(/^ich den zugeteilten Gegenstand auf der Zeile entferne$/) do
  find(@line_css).find(".icon-remove-sign").click
end

Dann(/^ist die Zeile nicht mehr grün markiert$/) do
  find(@line_css).native.attribute("class").should_not include "green"
end

Wenn(/^ich eine Option hinzufüge$/) do
  @option = @current_inventory_pool.options.first
  find("input#assign-or-add-input").set @option.inventory_code
  find("form#assign-or-add .ui-menu-item a", match: :first).click
  find("#flash")
  @option_line = @hand_over.user.contracts.approved.flat_map(&:lines).find{|l| l.item == @option}
  @line_css = ".line[data-id='#{@option_line.id}']"
end

Dann(/^wird das Problemfeld für das problematische Modell angezeigt$/) do
  @contract_line = @hand_over.lines.find do |l|
    if l.is_a? ItemLine
      av = l.model.availability_in(@current_inventory_pool).maximum_available_in_period_summed_for_groups(l.start_date, l.end_date, @hand_over.user.groups)
      l.start_date.past? and av > 1
    end
  end
  @line_css = ".line[data-id='#{@contract_line.id}']"
  step "die problematischen Auszeichnungen bleiben bei der Linie bestehen"
end

Wenn(/^ich dieser Linie einen Inventarcode manuell zuweise$/) do
  find(@line_css).find("input[data-assign-item]").click
  find(@line_css).find("li.ui-menu-item a", match: :first).click
end

Dann(/^die problematischen Auszeichnungen bleiben bei der Linie bestehen$/) do
  within(@line_css) do
    expect(has_selector?(".line-info.red")).to be true
    expect(has_selector?(".tooltip.red")).to be true
  end
end

Wenn(/^ich einen bereits hinzugefügten Gegenstand zuteile$/) do
  @contract_line = @hand_over.lines.find {|l| l.is_a? ItemLine and l.item}
  @line_css = ".line[data-id='#{@contract_line.id}']"
  find(@line_css).find("input[type='checkbox']").click

  find("input#assign-or-add-input").set @contract_line.item.inventory_code
  find("form#assign-or-add button .icon-plus-sign-alt", match: :first).click
end

Dann(/^erhalte ich eine entsprechende Info\-Meldung 'XY ist bereits diesem Vertrag zugewiesen'$/) do
  find "#flash", text: "#{@contract_line.item.inventory_code} ist bereits diesem Vertrag zugewiesen"
end

Angenommen(/^ich öffne eine Aushändigung mit mindestens einem zugewiesenen Gegenstand$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.find {|ho| ho.lines.any? &:item_id}
  step "ich die Aushändigung öffne"
end

Dann(/^die Zeile bleibt selektiert$/) do
  expect(has_selector?("#{@line_css} input[type='checkbox']:checked")).to be true
end

Dann(/^die Zeile bleibt grün markiert$/) do
  expect(has_selector?("#{@line_css}.green")).to be true
end

Angenommen(/^für den Gerätepark ist eine Standard\-Vertragsnotiz konfiguriert$/) do
  expect(@current_inventory_pool.default_contract_note).not_to be nil
end

Dann(/^erscheint ein Aushändigungsdialog$/) do
  expect(has_selector?(".modal [data-hand-over]")).to be true
end

Dann(/^diese Standard\-Vertragsnotiz erscheint im Textfeld für die Vertragsnotiz$/) do
  expect(find("textarea[name='note']").text).to eq @current_inventory_pool.default_contract_note
end

When(/^I change the quantity to "(.*?)"$/) do |arg1|
  within @line_css do
    find("input[data-line-quantity]").set arg1
    sleep(0.55)
  end
end

Then(/^the quantity will be restored to the original value$/) do
  within @line_css do
    expect(find("input[data-line-quantity]").value).to eq @option_line.reload.quantity.to_s
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
  @contract_line = @hand_over.lines.where(type: "OptionLine").sample
  @line_css = ".line[data-id='#{@contract_line.id}']"
  step "ich die Zeile wieder selektiere"
end

When(/^I select at least one line$/) do
  @line_css = all(".line[data-id]").to_a.sample
  step "ich die Zeile wieder selektiere"
end

Given(/^there exists a model with a problematic item$/) do
  @item = @current_inventory_pool.items.borrowable.in_stock.find {|item| item.is_broken? or item.is_incomplete?}
  expect(@item).not_to be nil
  @model = @item.model
  expect(@model).not_to be nil
end

And(/^I open a hand over for some user$/) do
  @user = @current_inventory_pool.users.sample
  visit manage_hand_over_path(@current_inventory_pool, @user)
end

When(/^I add this model to the hand over$/) do
  fill_in_via_autocomplete css: "#assign-or-add-input", value: @model.name
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

Given(/^there exists a model with a retired and a borrowable item$/) do
  @model = @current_inventory_pool.models.find { |m| m.items.borrowable.where(retired: nil).exists? and m.items.retired.exists? }
  expect(@model).not_to be nil
  @item = @model.items.retired.sample
end

Then(/^the retired item is not displayed in the list$/) do
  expect(page).not_to have_selector(".ui-menu .ui-menu-item", text: @item.inventory_code)
end
