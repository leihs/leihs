# -*- encoding : utf-8 -*-

When(/^ich unter meinem Benutzernamen auf "([^"]*)" klicke$/) do |arg|
  step "ich über meinen Namen fahre"
  find("a[href='#{borrow_user_documents_path}']").click
end

Dann(/^gelange ich zu der Dokumentenübersichtsseite/) do
  current_path.should == borrow_user_documents_path
end

Angenommen(/^ich befinde mich auf der Dokumentenübersichtsseite$/) do
  visit borrow_user_documents_path
end

Dann(/^sind die Verträge nach neuestem Zeitfenster sortiert$/) do
  dates = all("div.line-col", text: /\d{2}.\d{2}.\d{4}\s\-\s\d{2}.\d{2}.\d{4}/).map {|x| Date.parse(x.text.split.first) }
  dates.sort.should == dates
end

Dann(/^für jede Vertrag sehe ich folgende Informationen$/) do |table|
  contracts = @current_user.contracts.includes(:contract_lines).where(status: [:signed, :closed])
  contracts.sort! {|a,b| b.time_window_min <=> a.time_window_min}
  contracts.each do |contract|
    within(".line[data-id='#{contract.id}']") do
      table.raw.flatten.each do |s|
        case s
          when "Vertragsnummer"
            should have_content contract.id
          when "Zeitfenster mit von bis Datum und Dauer"
            should have_content contract.time_window_min.strftime("%d.%m.%Y")
            should have_content contract.time_window_max.strftime("%d.%m.%Y")
            should have_content (contract.time_window_max - contract.time_window_min).to_i.abs + 1
          when "Gerätepark"
            should have_content contract.inventory_pool.shortname
          when "Zweck"
            should have_content contract.purpose
          when "Status"
            should have_content _("Open") if contract.status == :signed
          when "Vertraglink"
            page.should have_selector("a[href='#{borrow_user_contract_path(contract.id)}']", text: _("Contract"))
          when "Wertelistelink"
            find("a[href='#{borrow_user_contract_path(contract.id)}'] + .dropdown-holder > .dropdown-toggle").hover
            page.should have_selector("a[href='#{borrow_user_value_list_path(contract.id)}']")
            find("a[href='#{borrow_user_contract_path(contract.id)}']").hover # release the previous hover
          else
            raise "unkown section"
        end
      end
    end
  end
end

Angenommen(/^ich drücke auf den Wertelistelink$/) do
  contracts = @current_user.contracts.where(status: [:signed, :closed])
  @contract = contracts.sample
  within(".row.line[data-id='#{@contract.id}']") do
    find(".dropdown-toggle").hover
    click_link _("Value List")
  end
end

Dann(/^öffnet sich die Werteliste$/) do
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
  current_path.should == borrow_user_value_list_path(@contract.id)
end

Angenommen(/^ich drücke auf den Vertraglink$/) do
  contracts = @current_user.contracts.where(status: [:signed, :closed])
  @contract = contracts.sample
  find("a[href='#{borrow_user_contract_path(@contract.id)}']", text: _("Contract")).click
end

Dann(/^öffnet sich der Vertrag$/) do
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
  current_path.should == borrow_user_contract_path(@contract.id)
end

Wenn(/^ich eine Werteliste aus meinen Dokumenten öffne$/) do
  contracts = @current_user.contracts.where(status: [:signed, :closed])
  @contract = contracts.sample
  visit borrow_user_value_list_path(@contract.id)
  step "öffnet sich die Werteliste"
  @value_list_element = first(".value_list")
end

Wenn(/^ich einen Vertrag aus meinen Dokumenten öffne$/) do
  contracts = @current_user.contracts.where(status: [:signed, :closed])
  @contract = contracts.sample
  visit borrow_user_contract_path(@contract.id)
  step "öffnet sich der Vertrag"
  @contract_element = first(".contract")
end

Wenn(/^ich einen Vertrag mit zurück gebrachten Gegenständen aus meinen Dokumenten öffne$/) do
  contracts = @current_user.contracts.where(status: [:signed, :closed])
  @contract = contracts.find {|c| c.lines.any? &:returned_to_user}
  visit borrow_user_contract_path(@contract.id)
  step "öffnet sich der Vertrag"
end

Dann(/^sehe ich die Werteliste genau wie im Verwalten\-Bereich$/) do
  steps %{
    Dann möchte ich die folgenden Bereiche in der Werteliste sehen:
    | Bereich          |
    | Datum            |
    | Titel            |
    | Ausleihender     |
    | Verleier         |
    | Liste            |
    Und die Modelle in der Werteliste sind alphabetisch sortiert

    Dann beinhaltet die Werte-Liste folgende Spalten:
    | Spaltenname     |
    | Laufende Nummer |
    | Inventarcode    |
    | Modellname      |
    | End Datum       |
    | Anzahl          |
    | Wert            |

    Dann gibt es eine Zeile für die totalen Werte
    Und diese summierte die Spalten:
     | Spaltenname |
     | Anzahl      |
     | Wert        |
  }
end

Dann(/^sehe ich den Vertrag genau wie im Verwalten-Bereich$/) do
  page.has_selector? ".contract"

  steps %{
    Dann möchte ich die folgenden Bereiche sehen:
      | Bereich                       |
      | Datum                         |
      | Titel                         |
      | Ausleihender                  |
      | Verleier                      |
      | Liste 1                       |
      | Liste 2                       |
      | Liste der Zwecke              |
      | Zusätzliche Notiz             |
      | Hinweis auf AGB               |
      | Unterschrift des Ausleihenden |
      | Seitennummer                  |
      | Barcode                       |
      | Vertragsnummer                |
    Und die Modelle sind innerhalb ihrer Gruppe alphabetisch sortiert

    Dann seh ich den Hinweis auf AGB "Es gelten die Ausleih- und Benutzungsreglemente des Verleihers."

    Dann beinhalten Liste 1 und Liste 2 folgende Spalten:
    | Spaltenname   |
    | Anzahl        |
    | Inventarcode  |
    | Modellname    |
    | Enddatum      |
    | Rückgabedatum / Rücknehmende Person |

    Dann sehe ich eine Liste Zwecken, getrennt durch Kommas
     Und jeder identische Zweck ist maximal einmal aufgelistet

    Dann sehe ich das heutige Datum oben rechts

    Dann sehe ich den Titel im Format "Leihvertrag Nr. #"

    Dann sehe ich den Barcode oben links

    Dann sehe ich den Ausleihenden oben links

    Dann sehe ich den Verleiher neben dem Ausleihenden

    Dann möchte ich im Feld des Ausleihenden die folgenden Bereiche sehen:
    | Bereich      |
    | Vorname      |
    | Nachname     |
    | Strasse      |
    | Hausnummer   |
    | Länderkürzel |
    | PLZ          |
    | Stadt        |
  }

  not_returned_lines, returned_lines = @contract.lines.partition {|line| line.returned_date.blank? }

  unless returned_lines.empty?
    @contract_element.text.should have_content _("Returned Items")
    @contract_element.all("tbody .returning_date").each do |date|
      date.text.should match @current_user.short_name
    end
  end

  unless not_returned_lines.empty?
    @contract_element.text.should have_content _("Borrowed Items")
    @contract_element.all("tbody .returning_date").each do |date|
      date.text.should == ""
    end
    not_returned_lines.each do |line|
      @contract_element.first(".not_returned_items").should have_content line.model.name
      @contract_element.first(".not_returned_items").should have_content line.item.inventory_code
    end
  end

  steps %{
    Dann wird die Adresse des Verleihers aufgeführt
  }
end

Dann(/^sieht man bei den betroffenen Linien die rücknehmende Person im Format "V. Nachname"$/) do
  if @contract_lines_to_take_back
    @contract_lines_to_take_back.map(&:contract).uniq.each do |contract|
      find(".button[target='_blank'][href='#{manage_contract_path(@ip, contract)}']").click
      new_window = page.driver.browser.window_handles.last
      page.within_window new_window do
        contract.lines.each do |cl|
          find(".contract .list.returned_items tr", text: cl.item.inventory_code).find(".returning_date", text: cl.returned_to_user.short_name)
        end
      end
    end
  elsif @contract
    lines = @contract.lines.where("returned_date IS NOT NULL")
    lines.size.should > 0
    lines.each do |cl|
      find(".contract .list.returned_items tr", text: cl.item.inventory_code).find(".returning_date", text: cl.returned_to_user.short_name)
    end
  end
end
