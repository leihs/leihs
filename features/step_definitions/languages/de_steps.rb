# -*- encoding : utf-8 -*-

Angenommen /^Personas existieren$/ do
  step 'personas existing'
end

Angenommen /^ich bin (.*?)$/ do |persona_name|
  step 'I am "%s"' % persona_name
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
