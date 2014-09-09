# -*- encoding : utf-8 -*-

Angenommen /^ich bin (.*?)$/ do |persona_name|
  step "I am %s" % persona_name
end

Wenn /^ich eine Rücknahme mache$/ do
  step 'I open a take back'
end

Wenn /^einem Gegenstand einen Inventarcode manuell zuweise$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
end

Wenn /^ich versuche, die Gegenstände auszuhändigen$/ do
  step 'I click hand over'
end

Wenn /^ich eine Aushändigung mache$/ do
  step 'I open a hand over which has multiple unassigned lines and models in stock'
end

Dann /^findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"$/ do
  step 'I follow "Admin"'
  step 'I follow "%s"' % _("Users")
end

Wenn(/^ich einen Gegenstand zurücknehme$/) do
  step 'I open a take back'
  step 'I select all lines of an open contract'
  step 'I click take back'
  step 'I see a summary of the things I selected for take back'
  step 'I click take back inside the dialog'
  step 'the contract is closed and all items are returned'
end

Wenn /^ich eine Bestellung bearbeite$/ do
  step 'I open a contract for acknowledgement'
end

Angenommen /^man öffnet einen Vertrag bei der Rücknahme/ do
  step 'I open a take back'
  step 'I select all lines of an open contract'
  step 'I click take back'
  step 'I click take back inside the dialog'
end

Wenn /^einige der ausgewählten Gegenstände hat keinen Zweck angegeben$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
  step 'I add an item to the hand over by providing an inventory code'
  step 'I add an option to the hand over by providing an inventory code and a date range'
end

Dann(/^kann man als "(.+)" keine, eine oder mehrere der folgenden Möglichkeiten in Form einer Checkbox auswählen:$/) do |arg, table|
  step %Q(one is able to choose for "#{arg}" none, one or more of the following options if form of a checkbox:), table
end

Wenn(/^ich als Betriebssystem keine, eine oder mehrere der vorhandenen Möglichkeiten auswähle$/) do
  step %Q(if I choose none, one or more of the available options for operating system)
end

Wenn(/^ich als Installation keine, eine oder mehrere der vorhandenen Möglichkeiten auswähle$/) do
  step %Q(if I choose none, one or more of the available options for installation)
end

Wenn(/^ich die Optionen für das Betriebssystem ändere$/) do
  step %Q(I change the options for operating system)
end

Wenn(/^ich die Optionen für die Installation ändere$/) do
  step %Q(I change the options for installation)
end

Angenommen(/^ein Modell existiert, welches keine Version hat$/) do
  step "there is a model without a version"
end

Wenn(/^ich dieses Modell dem Gegestand zuweise$/) do
  step "I assign this model to the item"
end

Dann(/^steht in dem Modellfeld nur der Produktname dieses Modell$/) do
  step "there is only product name in the input field of the model"
end

Dann(/^kann man als "(.*?)" einen der folgenden Möglichkeiten anhand eines Radio\-Buttons wählen:$/) do |arg1, table|
  step %Q(for "#{arg1}" one can select one of the following options with the help of radio button), table
end

Dann(/^kann man als "(.*?)" ein Datum auswählen$/) do |arg1|
  step %Q(for "#{arg1}" one can select a date)
end

Dann(/^die mögliche Werte für Maintenance\-Vertrag sind in der folgenden Reihenfolge:$/) do |table|
  step "for maintenance contract the available options are in the following order:", table
end

Dann(/^kann man als "(.*?)" eine Zahl eingeben$/) do |arg1|
  step %Q(for "#{arg1}" one can enter a number)
end

Dann(/^kann man als "(.*?)" einen Text eingeben$/) do |arg1|
  step %Q(for "#{arg1}" one can enter some text)
end

Dann(/^kann man als "(.*?)" einen Lieferanten auswählen$/) do |arg1|
  step %Q(for "#{arg1}" one can select a supplier)
end

Dann(/^kann man als "(.*?)" einen Gerätepark auswählen$/) do |arg1|
  step %Q(for "#{arg1}" one can select an inventory pool)
end

Wenn(/^ich als Lizenzablaufdatum ein Datum auswähle$/) do
  step %Q(I choose a date for license expiration)
end

Wenn(/^ich als Maintenance\-Vertrag "(.*?)" auswähle$/) do |arg1|
  step %Q(I choose "#{arg1}" for maintenance contract)
end

Dann(/^kann ich für den Maintenance\-Vertrag kein Ablaufdatum wählen$/) do
  step %Q(I am not able to choose the maintenance expiration date)
end

Wenn(/^ich für den Maintenance\-Vertrag ein Ablaufdatum wähle$/) do
  step %Q(I choose a date for the maintenance expiration)
end

Wenn(/^ich als Bezug "(.*?)" wähle$/) do |arg1|
  step %Q(I choose "#{arg1}" as reference)
end

Dann(/^muss ich eine Projektnummer eingeben$/) do
  step %Q(I have to enter a project number)
end

Wenn(/^ich das Lizenzablaufdatum ändere$/) do
  step %Q(I change the license expiration date)
end

Wenn(/^ich den Wert für den Maintenance\-Vertrag ändere$/) do
  step %Q(I change the value for maintenance contract)
end

Wenn(/^ich den Wert für Bezug ändere$/) do
  step %Q(I change the value for reference)
end

Wenn(/^ich der Aushändigung ein Gegenstand mit Hilfe eines Inventarcodes hinzufüge$/) do
  step %Q(I add an item to the hand over by providing an inventory code)
end

Wenn(/^ich der Aushändigung eine Lizenz mit Hilfe eines Inventarcodes hinzufüge$/) do
  step %Q(I add an license to the hand over by providing an inventory code)
end

Dann(/^wurde diese Aushändigung erfolgreich abgeschlossen$/) do
  step %Q(this hand over was completed successfully)
end

Wenn(/^ich die notwendigen Angaben im Aushändigungsdialog mache$/) do
  step %Q(I fill in all the necessary information in hand over dialog)
end

Dann(/^sind im Vertrag sowohl der Gegenstand als auch die Lizenz aufgeführt$/) do
  step %Q(there are inventory codes for item and license in the contract)
end

Angenommen(/^es existieren Software\-Produkte$/) do
  step "a software product exists"
end

Angenommen(/^es existiert eine Software\-Lizenz$/) do
  step "a software license exists"
end

Wenn(/^ich eine bestehende Software\-Lizenz kopiere$/) do
  step "I copy an existing software license"
end

Angenommen(/^es existiert ein(e)? (.*) mit folgenden Eigenschaften:$/) do |arg0, arg1, table|
  s = case arg1
        when "Modell"
          "model"
        when "Gegenstand"
          "item"
        when "Software-Produkt"
          "software product"
        when "Software-Lizenz"
          "software license"
        else
          raise "not found"
      end
  step "there is a #{s} with the following properties:", table
end

Wenn(/^ich (im Inventarbereich )?nach einer dieser (.*)?Eigenschaften suche$/) do |arg1, arg2|
  s1 = "in inventory "
  s2 = case arg2
         when "Software-Produkt "
           "software product "
         when "Software-Lizenz "
           "software license "
         else
           ""
       end
  step "I search #{s1}after one of those #{s2}properties"
end

Wenn(/^ich (im Inventarbereich )?nach den folgenden Eigenschaften suche$/) do |arg1, table|
  s1 = "in inventory "
  step "I search #{s1}after following properties", table
end

Dann(/^es erscheinen alle zutreffenden (.*)$/) do |arg1|
  s = case arg1
        when "Modelle"
          "models"
        when "Gegenstände"
          "items"
        when "Paket-Modelle"
          "package models"
        when "Paket-Gegenstände"
          "package items"
        when "Software-Produkte"
          "software products"
        when "Software-Lizenzen"
          "software licenses"
        when "Verträge, in denen diese Software-Produkt vorkommt"
          "contracts, in which this software product is contained"
        else
          raise "not found"
      end
  step "they appear all matched %s" % s
end

Angenommen(/^diese Software\-Lizenz ist an jemanden ausgeliehen$/) do
  step "this software license is handed over to somebody"
end

Wenn(/^ich nach dem Namen dieser Person suche$/) do
  step "I search after the name of that person"
end

Dann(/^erscheint der Vertrag dieser Person in den Suchresultaten$/) do
  step "it appears the contract of this person in the search results"
end

Dann(/^es erscheint diese Person in den Suchresultaten$/) do
  step "it appears this person in the search results"
end

Angenommen(/^es existieren für diese Produkte Software\-Lizenzen$/) do
  step "there exist licenses for this software product"
end

Wenn(/^ich diese in meinen Suchresultaten sehe$/) do
  step "I see these in my search result"
end

Dann(/^kann ich wählen, ausschliesslich Software\-Produkte aufzulisten$/) do
  step "I can select to list only software products"
end

Dann(/^ich kann wählen, ausschliesslich Software\-Lizenzen aufzulisten$/) do
  step "I can select to list only software licenses"
end

Wenn(/^ich dieses Software\-Produkt aus der Liste lösche$/) do
  step "I delete this software product from the list"
end

Dann(/^das Software\-Produkt wurde aus der Liste gelöscht$/) do
  step "the software product is deleted from the list"
end

Dann(/^das Software\-Produkt ist gelöscht$/) do
  step "the software product is deleted"
end

Wenn(/^ich alle Pflichtfelder für die Lizenz ausfülle$/) do
  step "I fill in all the required fields for the license"
end

Wenn(/^ich die Software setze$/) do
  step "I fill in the software"
end

Wenn(/^ich im Feld "(.*?)" den Wert "(.*?)" eingebe$/) do |field, value|
  step %Q(I fill in the field "#{field}" with the value "#{value}")
end

Dann(/^ist der "(.*?)" als "(.*?)" gespeichert$/) do |arg1, arg2|
  step %Q("#{arg1}" is saved as "#{arg2}")
end

Wenn(/^ich eine Software\-Lizenz mit gesetztem Maintenance\-Ablaufdatum, Lizenzablaufdatum und Rechnungsdatum editiere$/) do
  step %Q(I edit a license with set dates for maintenance expiration, license expiration and invoice date)
end

Wenn(/^ich die Daten für die folgenden Feldern lösche:$/) do |table|
  step %Q(I delete the data for the following fields:), table
end

Wenn(/^sind die folgenden Felder der Lizenz leer:$/) do |table|
  step %Q(the following fields of the license are empty:), table
end

Wenn(/^ich die gleiche Lizenz editiere$/) do
  step %Q(I edit the same license)
end

Wenn(/^ich für den Gerätepark die automatische Sperrung von Benutzern mit verspäteter Rückgaben einschalte$/) do
  step "on the inventory pool I enable the automatic suspension for users with overdue take backs"
end

Wenn(/^ein Benutzer bereits gesperrt ist$/) do
  step "a user is already suspended for this inventory pool"
end

Dann(/^werden der bestehende Sperrgrund sowie die Sperrzeit dieses Benutzers nicht überschrieben$/) do
  step "the existing suspension motivation and the suspended time for this user are not overwritten"
end

Angenommen(/^ich befinde mich in einer Rücknahme mit mindestens einem Gegenstand und einer Option$/) do
  step "I open a take back with at least one item and one option"
end

Wenn(/^ich bei der Option eine Stückzahl von (\d+) eingebe$/) do |n|
  step "I set a quantity of #{n} for the option line"
end

Wenn(/^beim Gegenstand eine Inspektion durchführe$/) do
  step "I inspect an item"
end

Wenn(/^ich setze "(.*?)" auf "(.*?)"$/) do |arg1, arg2|
  step %Q(I set "#{arg1}" to "#{arg2}")
end

Dann(/^steht bei der Option die zuvor angegebene Stückzahl$/) do
  step %Q(the option line has still the same quantity)
end

Wenn(/^ich die Anzahl "(.*?)" in das Mengenfeld schreibe$/) do |arg1|
  step "I change the quantity to \"%s\"" % arg1
end

Dann(/^wird die Menge mit dem ursprünglichen Wert überschrieben$/) do
  step "the quantity will be restored to the original value"
end

Dann(/^wird die Menge mit dem Wert "(.*?)" gespeichert$/) do |arg1|
  step "the quantity will be stored to the value \"%s\"" % arg1
end

Wenn(/^ich das Software\-Produkt wieder editiere$/) do
  step "I edit again this software product"
end

Dann(/^werden nur die Linien mit Links zusätzlich ausserhalb des Textfeldes angezeigt$/) do
  step "outside the the text field, they will additionally displayed lines with link only"
end

Angenommen(/^ich befinde mich in der Software\-Inventar\-Übersicht$/) do
  step "I'am on the software inventory overview"
end

Wenn(/^ich den CSV\-Export anwähle$/) do
  step "I press CSV-Export"
end

Dann(/^werden alle Lizenz\-Zeilen, wie gerade gemäss Filter angezeigt, exportiert$/) do
  step "all filtered software licenses will be exported"
end

Dann(/^die Zeilen enthalten alle Lizenz\-Felder$/) do
  step "the lines contain all license fields"
end

Angenommen /^ich erstelle eine? neues? (?:.+) oder ich ändere eine? bestehendes? (.+)$/ do |entity|
  step "ich add a new #{entity} or I change an existing #{entity}"
end

Wenn(/^ich dieses? "(.+)" aus der Liste lösche$/) do |entity|
  step %Q(I delete this #{entity} from the list)
end

Dann(/^(?:die|das) "(.+)" ist gelöscht$/) do |entity|
  step %Q(the "#{entity}" is deleted)
end

Angenommen(/^man editiert das Feld "(.*?)" eines ausgeliehenen Gegenstandes, wo man Besitzer ist$/) do |arg1|
  step %Q(one edits the field "#{arg1}" of an owned item not in stock)
end

Dann(/^sehe ich die "Software Informationen" angezeigt$/) do
  step %Q(I see the "Software Information")
end

Wenn(/^ich eine bestehende Software\-Lizenz mit Software\-Informationen, Anzahl-Zuteilungen und Anhängen editiere$/) do
  step %Q(I edit an existing software license with software information, quantity allocations and attachments)
end

Dann(/^die "Software Informationen" sind nicht editierbar$/) do
  step %Q(the software information is not editable)
end

Dann(/^die bestehende Links der "Software Informationen" öffnen beim Klicken in neuem Browser\-Tab$/) do
  step %Q(the links of software information open in a new tab upon clicking)
end

Dann(/^ich kann Modelle hinzufügen$/) do
  step "I can add models"
end

Dann(/^sehe ich die "Anhänge" der Software angezeigt$/) do
  step %Q(I see the attachments of the software)
end

Dann(/^ich kann die Anhänge in neuem Browser\-Tab öffnen$/) do
  step %Q(I can open the attachments in a new tab)
end

Wenn 'ich logge mich aus' do
  step "I make sure I am logged out"
end

Wenn(/^ich in das Zuteilungsfeld links vom Software\-Namen klicke$/) do
  step "I click on the assignment field of software names"
end

Dann(/^wird mir der Inventarcode sowie die vollständige Seriennummer angezeigt$/) do
  step "I see the inventory codes and the complete serial numbers of that software"
end

Wenn(/^der Hersteller bereits existiert$/) do
  step %(there exists already a manufacturer)
end

Dann(/^kann der Hersteller aus der Liste ausgewählt werden$/) do
  step %Q(the manufacturer can be selected from the list)
end

Wenn(/^ich einen nicht existierenden Hersteller eingebe$/) do
  step %Q(I set a non existing manufacturer)
end

Dann(/^der neue Hersteller ist in der Herstellerliste auffindbar$/) do
  step %Q(the new manufacturer can be found in the manufacturer list)
end

Wenn(/^ich als Aktivierungsart Dongle wähle$/) do
  step %Q(I choose dongle as activation type)
end

Dann(/^muss ich eine Dongle\-ID eingeben$/) do
  step %Q(I have to provide a dongle id)
end

Wenn(/^ich einen der folgenden Lizenztypen wähle:$/) do |table|
  step %Q(I choose one of the following license types), table
end

Wenn(/^ich eine Anzahl eingebe$/) do
  step %Q(I fill in a value)
end

Angenommen(/^es gibt eine Software\-Lizenz$/) do
  step %Q(there exists a software license)
end

Wenn(/^ich diese Lizenz in der Softwareliste anschaue$/) do
  step %Q(I look at this license in the software list)
end

Angenommen(/^es gibt eine Software\-Lizenz mit einem der folgenden Typen:$/) do |table|
  step %Q(there exists a software license of one of the following types), table
end

Angenommen(/^es gibt eine Software\-Lizenz, wo meine Abteilung der Besitzer ist, die Verantwortung aber auf eine andere Abteilung abgetreten hat$/) do
  step %Q(there exists a software license, owned by my inventory pool, but given responsibility to another inventory pool)
end

Angenommen(/^es gibt eine Software\-Lizenz, die nicht an Lager ist und eine andere Abteilung für die Software\-Lizenz verantwortlich ist$/) do
  step %Q(there exists a software license, which is not in stock and another inventory pool is responsible for it)
end

Wenn(/^der Vertrag eine Software\-Lizenz beinhaltet$/) do
  step "the contract contains a software license"
end

Dann(/^sehe ich zusätzlich die folgende Information$/) do |table|
  step "I additionally see the following informatins", table
end

Angenommen(/^ich editiere eine Gerätepark( bei dem die aut. Zuweisung aktiviert ist)?$/) do |arg1|
  step "I edit an inventory pool%s" % (arg1 ? " which has the automatic access enabled" : nil)
end

Wenn(/^ich "(.*)" aktiviere$/) do |arg1|
  step %Q(I enable "%s") % arg1
end

Dann(/^ist "(.*)" aktiviert$/) do |arg1|
  step %Q("%s" is enabled) % arg1
end

Wenn(/^ich "(.*)" deaktiviere$/) do |arg1|
  step %Q(I disable "%s") % arg1
end

Dann(/^ist "(.*)" deaktiviert$/) do |arg1|
  step %Q("%s" is disabled) % arg1
end

Angenommen(/^eine Software\-Produkt mit mehr als (\d+) Zeilen Text im Feld "(.*?)" existiert$/) do |arg1, arg2|
  step %Q(a software product with more than %d text rows in field "%s" exists) % [arg1, arg2]
end

Wenn(/^ich diese Software editiere$/) do
  step "I edit this software"
end

Wenn(/^ich in das Feld "(.*?)" klicke$/) do |arg1|
  step %Q(I click in the field "%s") % arg1
end

Dann(/^wächst das Feld, bis es den ganzen Text anzeigt$/) do
  step "this field grows up till showing the complete text"
end

Wenn(/^ich aus dem Feld herausgehe$/) do
  step "I release the focus from this field"
end

Dann(/^schrumpft das Feld wieder auf die Ausgangsgrösse$/) do
  step "this field shrinks back to the original size"
end

Dann(/^alle die zugeteilten Gegenstände erhalten dieselben Werte, die auf diesem Paket erfasst sind$/) do |table|
  step "all the packaged items receive these same values store to this package", table
end

Angenommen(/^diese Modell ein Paket ist$/) do
  step "this model is a package"
end

Angenommen(/^diese Paket\-Gegenstand ist Teil des Pakets\-Modells$/) do
  step "this package item is part of this package model"
end

Angenommen(/^dieser Gegenstand ist Teil des Paket\-Gegenstandes$/) do
  step "this item is part of this package item"
end

Wenn(/^man öffnet (eine|die) Rüstliste( für einen unterschriebenen Vertrag)?$/) do |arg1, arg2|
  s1 = case arg1
         when "eine"
           "a"
         when "die"
           "the"
       end
  s2 = arg2 ? " for a signed contract" : ""
  step "I open %s picking list%s" % [s1, s2]
end

Wenn(/^man befindet sich im Verleih\-Bereich$/) do
  step "I visit the lending section"
end

Wenn(/^ich mich im Verleih im Reiter (aller|der offenen|der geschlossenen) Verträge befinde$/) do |arg1|
  s = case arg1
        when "aller"
          "all"
        when "der offenen"
          "open"
        when "der geschlossenen"
          "closed"
      end
  step "I visit the lending section on the list of %s contracts" % s
end

Wenn(/^ich sehe mindestens (eine Bestellung|einen Vertrag)$/) do |arg1|
  case arg1
    when "einen Vertrag"
      step "I see at least a contract"
    when "eine Bestellung"
      step "I see at least an order"
  end
end

Dann(/^kann ich die Rüstliste auf den jeweiligen (Bestell|Vertrags)\-Zeilen öffnen$/) do |arg1|
  s = case arg1
        when "Bestell"
          "order"
        when "Vertrags"
          "contract"
      end
  step "I can open the picking list of any %s line" % s
end

Wenn(/^ich mich im Verleih in einer Aushändigung befinde$/) do
  step "I open a hand over which has multiple lines"
end

Wenn(/^ich mindestens eine Zeile in dieser Aushändigung markiere$/) do
  step "I select at least one line"
end

Dann(/^kann ich die Rüstliste öffnen$/) do
  step "I can open the picking list"
end

Angenommen(/^ein Gegenstand zugeteilt ist und diese Zeile markiert ist$/) do
  step "ich dem nicht problematischen Modell einen Inventarcode zuweise"
  step "wird der Gegenstand der Zeile zugeteilt"
end

Angenommen(/^einer Zeile noch kein Gegenstand zugeteilt ist und diese Zeile markiert ist$/) do
  step "a line has no item assigned yet and this line is marked"
end

Angenommen(/^einer Zeile mit einem Gegenstand ohne zugeteilt Raum und Gestell markiert ist$/) do
  step "a line with an assigned item which doesn't have a location is marked"
end

Angenommen(/^eine Option markiert ist$/) do
  step "an option line is marked"
end

Dann(/^sind die Listen zuerst nach (Ausleihdatum|Rückgabedatum) sortiert$/) do |arg1|
  s = case arg1
        when "Ausleihdatum"
          "hand over"
        when "Rückgabedatum"
          "take back"
        else
          raise "not found"
      end
  step "the lists are sorted by %s date" % s
end

Dann(/^jede Liste beinhaltet folgende Spalten:$/) do |table|
  step "each list contains following columns", table
end

Dann(/^innerhalb jeder Liste wird nach Raum und Gestell sortiert$/) do
  step "each list will sorted after room and shelf"
end

Dann(/^innerhalb jeder Liste wird nach Modell, dann nach Raum und Gestell des meistverfügbaren Ortes sortiert$/) do
  step "each list will sorted after models, then sorted after room and shelf of the most available locations"
end

Dann(/^in der Liste wird der Inventarcode des zugeteilten Gegenstandes mit Angabe dessen Raums und Gestells angezeigt$/) do
  step "in the list, the assigned items will displayed with inventory code, room and shelf"
end

Dann(/^in der Liste wird der nicht zugeteilte Gegenstand ohne Angabe eines Inventarcodes angezeigt$/) do
  step "in the list, the not assigned items will displayed without inventory code"
end

Dann(/^Gegenständen kein Raum oder Gestell zugeteilt sind, wird (die verfügbare Anzahl für den Kunden und )?"(.*?)" angezeigt$/) do |arg1, arg2|
  s1 = arg1 ? "the available quantity for this customer and " : nil
  s2 = case arg2
         when "x Ort nicht definiert"
           "x %s" % _("Location not defined")
         when "Ort nicht definiert"
           _("Location not defined")
         else
           raise "not found"
       end
  step %Q(the items without location, are displayed with #{s1}"#{s2}")
end

Dann(/^fehlende Rauminformationen bei Optionen werden als "(.*?)" angezeigt$/) do |arg1|
  s = case arg1
        when "Ort nicht definiert"
          _("Location not defined")
        else
          raise "not found"
      end
  step %Q(the missing location information for options, are displayed with "#{s}")
end

Dann(/^nicht verfügbaren Gegenständen, wird "(.*?)" angezeigt$/) do |arg1|
  step %Q(the not available items, are displayed with "#{arg1}")
end

Dann(/^wird die Editieransicht der neuen Software\-Lizenz geöffnet$/) do
  step "it opens the edit view of the new software license"
end

Angenommen(/^es existieren (Bestellungen|Verträge|Besuche)$/) do |arg1|
  s = case arg1
        when "Bestellungen"
          "orders"
        when "Verträge"
          "contracts"
        when "Besuche"
          "visits"
        else
          raise "not found"
      end
  step "%s exist" % s
end

Wenn(/^ich mich auf der Liste der (Bestellungen|Verträge|Besuche) befinde$/) do |arg1|
  s = case arg1
        when "Bestellungen"
          "orders"
        when "Verträge"
          "contracts"
        when "Besuche"
          "visits"
        else
          raise "not found"
      end
  step "I am listing the %s" % s

end

Wenn(/^ich nach (einer Bestellung|einem Vertrag|einem Besuch) suche$/) do |arg1|
  s = case arg1
        when "einer Bestellung"
          "an order"
        when "einem Vertrag"
          "a contract"
        when "einem Besuch"
          "a visit"
        else
          raise "not found"
      end
  step "I search for %s" % s
end

Dann(/^werden mir alle (Bestellungen|Verträge|Besuche) aufgeführt, die zu meinem Suchbegriff passen$/) do |arg1|
  s = case arg1
        when "Bestellungen"
          "orders"
        when "Verträge"
          "contracts"
        when "Besuche"
          "visits"
        else
          raise "not found"
      end
  step "all listed %s, are matched by the search term" % s
end

Wenn(/^ich einen Suchbegriff bestehend aus mindestens zwei Wörtern und einem Leerschlage eigebe$/) do
  step "I search for models giving at least two space separated terms"
end

Wenn(/^ich den Wert der Notiz ändere$/) do
  step %Q(I change the value of the note)
end

Wenn(/^ich die Dongle\-ID ändere$/) do
  step %Q(I change the value of dongle id)
end

Wenn(/^ich die Gesamtanzahl ändere$/) do
  step %Q(I change the value of total quantity)
end

Wenn(/^ich die Anzahl\-Zuteilungen ändere$/) do
  step %Q(I change the quantity allocations)
end

Wenn(/^ich eine Gesamtanzahl eingebe$/) do
  step %Q(I fill in the value of total quantity)
end

Wenn(/^ich die Anzahl\-Zuteilungen hinzufüge$/) do
  step %Q(I add the quantity allocations)
end

Wenn(/^ich die Gesamtanzahl "(.*?)" eingebe$/) do |arg1|
  step %Q(I fill in total quantity with value "#{arg1}")
end

Dann(/^wird mir die verbleibende Anzahl der Lizenzen wie folgt angezeigt "(.*?)"$/) do |arg1|
  step %Q(I see the remaining number of licenses shown as follows "#{arg1}")
end

Dann(/^ich die folgenden Anzahl\-Zuteilungen hinzufüge$/) do |table|
  step %Q(I add the following quantity allocations:), table
end

Wenn(/^ich die folgenden Anzahl\-Zuteilungen lösche$/) do |table|
  step %Q(I delete the following quantity allocations:), table
end

Dann(/^der (.*) heisst "(.*?)"$/) do |arg1, arg2|
  s = case arg1
        when "Titel"
          "title"
        when "Speichern-Button"
          "save button"
        else
          raise "not found"
      end
  step %Q(the #{s} is labeled as "#{arg2}")
end

Dann(/^ist die neue Lizenz erstellt$/) do
  step "the new software license is created"
end

Dann(/^wurden die folgenden Felder von der kopierten Lizenz übernommen$/) do |table|
  step "the following fields were copied from the original software license", table
end

Dann(/^kann ich die bestehende Software-Lizenz kopieren$/) do
  step "I can copy an existing software license"
end

Dann(/^kann ich die bestehende Software-Lizenz speichern und kopieren$/) do
  step "I can save and copy the existing software license"
end

Angenommen(/^es existiert ein Vertrag mit Status "(.*?)" für einen Benutzer mit sonst keinem anderen Verträgen$/) do |arg1|
  step %Q(there exists a contract with status "#{arg1}" for a user with otherwise no other contracts)
end

Wenn(/^man den Benutzer für diesen Vertrag editiert$/) do
  step %Q(I edit the user of this contract)
end

Dann(/^hat dieser Benutzer Zugriff auf das aktuelle Inventarpool$/) do
  step %Q(this user has access to the current inventory pool)
end

Dann(/^erhalte ich die Fehlermeldung "(.*?)"$/) do |arg1|
  step %Q(I see the error message "#{arg1}")
end

Wenn(/^ich innerhalb des gesamten Inventars als "(.*?)" die Option "(.*?)" wähle$/) do |arg1, arg2|
  step %Q(I choose inside all inventory as "#{arg1}" the option "#{arg2}")
end

Dann(/^wird nur das "(.*?)" Inventar angezeigt$/) do |arg1|
  step %Q(only the "#{arg1}" inventory is shown)
end

Angenommen(/^ich sehe ausgemustertes und nicht ausgemustertes Inventar$/) do
  step %Q(I see retired and not retired inventory)
end

Wenn(/^ich innerhalb des gesamten Inventars die "(.*?)" setze$/) do |arg1|
  step %Q(I set the option "#{arg1}" inside of the full inventory)
end

Dann(/^ist bei folgenden Inventargruppen der Filter "(.*?)" per Default eingestellt:$/) do |arg1, table|
  step %Q(for the following inventory groups the filter "#{arg1}" is set), table
end

Angenommen(/^man befindet sich auf der Liste der Optionen$/) do
  step %Q(one is on the list of the options)
end

Wenn(/^ich innerhalb des gesamten Inventars ein bestimmtes verantwortliche Gerätepark wähle$/) do
  step %Q(I choose a certain responsible pool inside the whole inventory)
end

Dann(/^wird nur das Inventar angezeigt, für welche dieses Gerätepark verantwortlich ist$/) do
  step %Q(only the inventory is shown, for which this pool is responsible)
end

Wenn(/^ich(?: erneut)? auf die Geraetepark\-Auswahl klicke$/) do
  step %Q(I click on the inventory pool selection toggler again)
end

Dann(/^sehe ich alle Geraeteparks, zu denen ich Zugriff als Verwalter habe$/) do
  step %Q(I see all inventory pools for which I am a manager)
end

Wenn(/^ich auf einen Geraetepark klicke$/) do
  step %Q(I click on one of the inventory pools)
end

Dann(/^wechsle ich zu diesem Geraetepark$/) do
  step %Q(I switch to that inventory pool)
end

Wenn(/^ich ausserhalb der Geraetepark\-Auswahl klicke$/) do
  step %Q(I click somewhere outside of the inventory pool menu list)
end

Dann(/^schliesst sich die Geraetepark\-Auswahl$/) do
  step %Q(the inventory pool menu list closes)
end

Dann(/^sehe ich alle Geraeteparks$/) do
  step %Q(I see all the inventory pools)
end

Dann(/^erscheint das entsprechende Modell zum Gegenstand$/) do
  step %Q(appears the corresponding model to the item)
end

Dann(/^es erscheint der Gegenstand$/) do
  step %Q(appears the item)
end

Wenn(/^ich füge ein Bild hinzu$/) do
  step %Q(I add an image)
end

Dann(/^kann ich kein zweites Bild hinzufügen$/) do
  step %Q(I can not add a second image)
end

Angenommen(/^es existiert eine Kategorie mit Bild$/) do
  step %Q(there exists a category with an image)
end

Wenn(/^ich das Bild entferne$/) do
  step %Q(I remove the image)
end

Angenommen(/^man editiert diese Kategorie$/) do
  step %Q(one edits this category)
end

Wenn(/^ich ein neues Bild wähle$/) do
  step %Q(I add a new image)
end

Dann(/^ist die Kategorie mit dem neuen Bild gespeichert$/) do
  step %Q(the category was saved with the new image)
end

Dann(/^man sieht für jede Kategorie ihr Bild, oder falls nicht vorhanden, das erste Bild eines Modells dieser Kategorie$/) do
  step %Q(one sees for each category its image, or if not set, the first image of a model from this category)
end

Angenommen(/^es existiert eine Hauptkategorie mit eigenem Bild$/) do
  step %Q(there exists a main category with own image)
end

Angenommen(/^es existiert eine Hauptkategorie ohne eigenes Bild aber mit einem Modell mit Bild$/) do
  step %Q(there exists a main category without own image but with a model with image)
end

Dann(/^sehe ich nur diejenigen Pakete, für welche ich verantwortlich bin$/) do
  step "I only see packages which I am responsible for"
end

Angenommen(/^ich befinde mich auf der Liste eines "(.*?)"en Inventars$/) do |arg1|
  step %Q(I see the list of "#{arg1}" inventory)
end

Wenn(/^ich eine Modellzeile öffne$/) do
  step %Q(I open a model line)
end

Dann(/^ist die Gegenstandszeile mit "(.*?)" in rot ausgezeichnet$/) do |arg1|
  step %Q(the item line ist marked as "#{arg1}" in red)
end

Angenommen(/^es exisitert ein Gegenstand mit mehreren Problemen$/) do
  step %Q(there exists an item with many problems)
end

Wenn(/^ich nach diesem Gegenstand in der Inventarliste suche$/) do
  step %Q(I search after this item in the inventory list)
end

Wenn(/^ich öffne die Modellzeile von diesem Gegenstand$/) do
  step %Q(I open the model line of this item)
end

Dann(/^sind die Probleme des Gegestandes komma getrennt aneinander gereiht$/) do
  step %Q(the problems of this item are displayed separated by a comma)
end

Angenommen(/^es gibt in meinem Gerätepark einen "(.*?)"en Gegenstand$/) do |arg1|
  step %Q(there is a "#{arg1}" item in my inventory pool)
end

Wenn(/^ich anhand der Inventarnummer nach diesem Gegenstand global suche$/) do
  step %Q(I search globally after this item with its inventory code)
end

Dann(/^sehe ich diesen Gegenstand im Gegenstände\-Container$/) do
  step %Q(I see the item in the items container)
end

Dann(/^die Gegenstandszeile ist mit "(.*?)" in rot ausgezeichnet$/) do |arg1|
  step %Q(the item line ist marked as "#{arg1}" in red)
end

Angenommen(/^es gibt einen geschlossenen Vertrag mit ausgemustertem Gegenstand$/) do
  step %Q(there exists a closed contract with a retired item)
end

Dann(/^sehe ich ihn im Gegenstände\-Container$/) do
  step %Q(I see the item in the items container)
end

Dann(/^wenn ich über die Liste der Gegenstände auf der Vertragslinie hovere$/) do
  step %Q(I hover over the list of items on the contract line)
end

Dann(/^sehe ich im Tooltip das Modell dieses Gegenstandes$/) do
  step %Q(I see in the tooltip the model of this item)
end

Angenommen(/^es gibt einen geschlossenen Vertrag mit einem Gegenstand, wofür ein anderer Gerätepark verantwortlich und Besitzer ist$/) do
  step %Q(there exists a closed contract with an item, for which an other inventory pool is responsible and owner)
end

Dann(/^sehe ich keinen Gegenstände\-Container$/) do
  step %Q(I do not see the items container)
end

Angenommen(/^heute entspricht dem Startdatum der Bestellung$/) do
  step %Q(today corresponds to the start date of the order)
end
