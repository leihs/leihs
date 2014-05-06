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
  step 'I add an item to the hand over by providing an inventory code and a date range'
  step 'I add an option to the hand over by providing an inventory code and a date range'
end

Dann(/^kann man als "(.+)" keine, eine oder mehrere der folgenden Möglichkeiten in Form einer Checkbox auswählen:$/) do |arg, table|
  step %Q(one is able to choose as "#{arg}" none, one or more of the following options:), table
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
