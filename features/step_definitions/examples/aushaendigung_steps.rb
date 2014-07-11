# -*- encoding : utf-8 -*-

Angenommen(/^es besteht bereits eine Aushändigung mit mindestens (\d+) zugewiesenen Gegenständen für einen Benutzer$/) do |count|
  @hand_over = @current_inventory_pool.visits.hand_over.find {|ho| ho.contract_lines.select(&:item).size >= count.to_i}
  @hand_over.should_not be_nil
end

Wenn(/^ich die Aushändigung öffne$/) do
  visit manage_hand_over_path(@current_inventory_pool, @hand_over.user)
end

Dann(/^sehe ich all die bereits zugewiesenen Gegenstände mittels Inventarcodes$/) do
  @hand_over.contract_lines.each {|l| find("[data-assign-item][disabled][value='#{l.item.inventory_code}']") }
end

When(/^der Benutzer für die Aushändigung ist gesperrt$/) do
  ensure_suspended_user(@customer, @ip)
  visit manage_hand_over_path(@ip, @customer)
end

Angenommen(/^ich öffne eine Aushändigung( mit einer Software)?$/) do |arg1|
  @hand_over = if arg1
                 @current_inventory_pool.visits.hand_over.shuffle.detect {|v| v.contract_lines.any?{|cl| cl.model.is_a? Software } }
               else
                 @current_inventory_pool.visits.hand_over.sample
               end
  step "ich die Aushändigung öffne"
end

Angenommen(/^es gibt eine Aushändigung mit mindestens einem nicht problematischen Modell$/) do
  @models_in_stock = Item.by_responsible_or_owner_as_fallback(@current_inventory_pool).in_stock.map(&:model).uniq
  @hand_over = @current_inventory_pool.visits.hand_over.detect do |v|
    v.lines.select do |l|
      !l.start_date.past? and !l.item and @models_in_stock.include?(l.model)
    end.count >= 1
  end
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
  @contract_line.reload.item.should_not be_nil
end

Dann(/^die Zeile wird selektiert|wird die Zeile selektiert$/) do
  find(@line_css).find("input[type=checkbox]").should be_checked
end

Dann(/^die Zeile wird grün markiert|wird die Zeile grün markiert$/) do
  find(@line_css).native.attribute("class").should include "green"
end

Wenn(/^ich die Zeile deselektiere$/) do
  within @line_css do
    find("input[type=checkbox]").click
    find("input[type=checkbox]").should_not be_checked
  end
end

Dann(/^ist die Zeile nicht mehr grün eingefärbt$/) do
  find(@line_css).native.attribute("class").should_not include "green"
end

Wenn(/^ich die Zeile wieder selektiere$/) do
  within @line_css do
    find("input[type=checkbox]").click
    find("input[type=checkbox]").should be_checked
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

Angenommen(/^es gibt eine Aushändigung mit mindestens einer problematischen Linie$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.find {|ho| ho.lines.any? do |l|
    if l.is_a? ItemLine
      av = l.model.availability_in(@current_inventory_pool).maximum_available_in_period_summed_for_groups(l.start_date, l.end_date, ho.user.groups)
      l.start_date.past? and av > 1
    end
  end }
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
    should have_selector ".line-info.red"
    should have_selector ".tooltip.red"
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
  page.should have_selector "#{@line_css} input[type='checkbox']:checked"
end

Dann(/^die Zeile bleibt grün markiert$/) do
  page.should have_selector "#{@line_css}.green"
end

Angenommen(/^für den Gerätepark ist eine Standard\-Vertragsnotiz konfiguriert$/) do
  @current_inventory_pool.default_contract_note.should_not be_nil
end

Dann(/^erscheint ein Aushändigungsdialog$/) do
  page.should have_selector ".modal [data-hand-over]"
end

Dann(/^diese Standard\-Vertragsnotiz erscheint im Textfeld für die Vertragsnotiz$/) do
  find("textarea[name='note']").text.should == @current_inventory_pool.default_contract_note
end

When(/^I change the quantity to "(.*?)"$/) do |arg1|
  within @line_css do
    find("input[data-line-quantity]").set arg1
    sleep(0.55)
  end
end

Then(/^the quantity will be restored to the original value$/) do
  within @line_css do
    find("input[data-line-quantity]").value.should == @option_line.reload.quantity.to_s
  end
end

Then(/^the quantity will be stored to the value "(.*?)"$/) do |arg1|
  step "the quantity will be restored to the original value"
  @option_line.quantity.to_s.should == arg1
end

Given(/^a line has no item assigned yet and this line is marked$/) do
  step "I can add models"
  @contract_line = @hand_over.lines.find {|l| not l.item }
  @line_css = ".line[data-id='#{@contract_line.id}']"
  step "ich die Zeile wieder selektiere"
end

When(/^I select at least one line$/) do
  @line_css = all(".line[data-id]").to_a.sample
  step "ich die Zeile wieder selektiere"
end
