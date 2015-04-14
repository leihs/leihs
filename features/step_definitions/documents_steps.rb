# -*- encoding : utf-8 -*-

#When(/^ich unter meinem Benutzernamen auf "([^"]*)" klicke$/) do |arg|
When(/^I click on "([^"]*)" underneath my username$/) do |arg|
  #step "ich über meinen Namen fahre"
  step "I hover over my name"
  find("a[href='#{borrow_user_documents_path}']").click
end

#Dann(/^gelange ich zu der Dokumentenübersichtsseite/) do
Then(/^I am on the page showing my documents/) do
  expect(current_path).to eq borrow_user_documents_path
end

#Angenommen(/^ich befinde mich auf der Dokumentenübersichtsseite$/) do
Given(/^I am on my documents page$/) do
  visit borrow_user_documents_path
end

#Dann(/^sind die Verträge nach neuestem Zeitfenster sortiert$/) do
Then(/^my contracts are ordered by the earliest time window$/) do
  dates = all("div.line-col", text: /\d{2}.\d{2}.\d{4}\s\-\s\d{2}.\d{2}.\d{4}/).map {|x| Date.parse(x.text.split.first) }
  expect(dates.sort).to eq dates
end

#Dann(/^für jede Vertrag sehe ich folgende Informationen$/) do |table|
Then(/^I see the following information for each contract:$/) do |table|
  contracts = @current_user.contracts.signed_or_closed.sort {|a,b| b.time_window_min <=> a.time_window_min}
  contracts.each do |contract|
    within(".line[data-id='#{contract.id}']") do
      table.raw.flatten.each do |s|
        case s
          when "Contract number"
            expect(has_content?(contract.id)).to be true
          when "Time window with its start and end"
            expect(has_content?(contract.time_window_min.strftime("%d/%m/%Y"))).to be true
            expect(has_content?(contract.time_window_max.strftime("%d/%m/%Y"))).to be true
            expect(has_content?((contract.time_window_max - contract.time_window_min).to_i.abs + 1)).to be true
          when "Inventory pool"
            expect(has_content?(contract.inventory_pool.shortname)).to be true
          when "Purpose"
            expect(has_content?(contract.purpose)).to be true
          when "Status"
            expect(has_content?(_("Open"))).to be true if contract.status == :signed
          when "Link to the contract"
            expect(has_selector?("a[href='#{borrow_user_contract_path(contract.id)}']", text: _("Contract"))).to be true
          when "Link to the value list"
            find("a[href='#{borrow_user_contract_path(contract.id)}'] + .dropdown-holder > .dropdown-toggle").click
            expect(has_selector?("a[href='#{borrow_user_value_list_path(contract.id)}']")).to be true
            find("a[href='#{borrow_user_contract_path(contract.id)}']").click # release the previous click
          else
            raise "unkown section"
        end
      end
    end
  end
end

#Angenommen(/^ich drücke auf den Wertelistelink$/) do
Given(/^I click the value list link$/) do
  @contract = @current_user.contracts.signed_or_closed.order("RAND()").first
  within(".row.line[data-id='#{@contract.id}']") do
    find(".dropdown-toggle").click
    document_window = window_opened_by do
      click_link _("Value List")
    end
    page.driver.browser.switch_to.window(document_window.handle)
  end
end

#Dann(/^öffnet sich die Werteliste$/) do
Then(/^the value list opens$/) do
  expect(current_path).to eq borrow_user_value_list_path(@contract.id)
end

#Angenommen(/^ich drücke auf den Vertraglink$/) do
Given(/^I click the contract link$/) do
  @contract = @current_user.contracts.signed_or_closed.order("RAND()").first
  document_window = window_opened_by do
    find("a[href='#{borrow_user_contract_path(@contract.id)}']", text: _("Contract")).click
  end
  page.driver.browser.switch_to.window(document_window.handle)
end

#Dann(/^öffnet sich der Vertrag$/) do
Then(/^the contract opens$/) do
  expect(current_path).to eq borrow_user_contract_path(@contract.id)
end

#Wenn(/^ich eine Werteliste aus meinen Dokumenten öffne$/) do
When(/^I open a value list from my documents$/) do
  @contract = @current_user.contracts.signed_or_closed.order("RAND()").first
  visit borrow_user_value_list_path(@contract.id)
  #step "öffnet sich die Werteliste"
  step 'the value list opens'
  @list_element = find(".value_list")
end

#Wenn(/^ich einen Vertrag aus meinen Dokumenten öffne$/) do
When(/^I open a contract from my documents$/) do
  @contract = @current_user.contracts.signed_or_closed.order("RAND()").first
  visit borrow_user_contract_path(@contract.id)
  #step "öffnet sich der Vertrag"
  step 'the contract opens'
  @contract_element = find(".contract", match: :first)
end

#Wenn(/^ich einen Vertrag mit zurück gebrachten Gegenständen aus meinen Dokumenten öffne$/) do
When(/^I open a contract with returned items from my documents$/) do
  @contract = @current_user.contracts.signed_or_closed.find {|c| c.lines.any? &:returned_to_user}
  visit borrow_user_contract_path(@contract.id)
  step "öffnet sich der Vertrag"
end

#Dann(/^sehe ich die Werteliste genau wie im Verwalten\-Bereich$/) do
Then(/^I see the value list displayed as in the manage section$/) do
  pending
  # This kind of step reuse is pointless since it does not automatically
  # update when the step sequence for the manage section changes.
  # We should instead make the steps below into a reusable thing
  #steps %{
  #  Dann möchte ich die folgenden Bereiche in der Werteliste sehen:
  #  | Bereich          |
  #  | Datum            |
  #  | Titel            |
  #  | Ausleihender     |
  #  | Verleier         |
  #  | Liste            |
  #  Und die Modelle in der Werteliste sind alphabetisch sortiert

  #  Dann beinhaltet die Liste folgende Spalten:
  #  | Spaltenname     |
  #  | Laufende Nummer |
  #  | Inventarcode    |
  #  | Modellname      |
  #  | End Datum       |
  #  | Anzahl          |
  #  | Wert            |

  #  Dann gibt es eine Zeile für die totalen Werte
  #  Und diese summierte die Spalten:
  #   | Spaltenname |
  #   | Anzahl      |
  #   | Wert        |
  #}
end

#Dann(/^sehe ich den Vertrag genau wie im Verwalten-Bereich$/) do
Then(/^I see the contract and it looks like in the manage section$/) do
  expect(has_selector?(".contract")).to be true
  # The rest is deleted: Dito, see above.
end

#Dann(/^sieht man bei den betroffenen Linien die rücknehmende Person im Format "V. Nachname"$/) do
Then(/^the relevant lines show the person taking back the item in the format "F. Lastname"$/) do
  if @contract_lines_to_take_back
    @contract_lines_to_take_back.map(&:contract).uniq.each do |contract|
      new_window = window_opened_by do
        find(".button[target='_blank'][href='#{manage_contract_path(@current_inventory_pool, contract)}']").click
      end
      within_window new_window do
        contract.lines.each do |cl|
          find(".contract .list.returned_items tr", text: /#{cl.quantity}.*#{cl.item.inventory_code}.*#{I18n.l cl.end_date}/).find(".returning_date", text: cl.returned_to_user.short_name)
        end
      end
    end
  elsif @contract
    lines = @contract.lines.where.not(returned_date: nil)
    expect(lines.size).to be > 0
    lines.each do |cl|
      find(".contract .list.returned_items tr", text: cl.item.inventory_code).find(".returning_date", text: cl.returned_to_user.short_name)
    end
  end
end
