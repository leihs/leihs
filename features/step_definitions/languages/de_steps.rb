# -*- encoding : utf-8 -*-

#Wenn(/^ich (im Inventarbereich )?nach einer dieser (.*)?Eigenschaften suche$/) do |arg1, arg2|

# Don't translate -- use step below
When(/^I search for one of these (.*)?properties (in the inventory section)?$/) do |arg1, arg2|
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

Dann(/^Gegenständen kein Raum oder Gestell zugeteilt sind, wird (die verfügbare Anzahl für den Kunden und )?"(.*?)" angezeigt$/) do |arg1, arg2|
  s1 = arg1 ? "the available quantity for this customer and " : nil
  s2 = case arg2
         when "x Ort nicht definiert"
           "x %s" % _("Location not defined")
         when "Ort nicht definiert"
           _("Location not defined")
         else
           raise
       end
  step %Q(the items without location, are displayed with #{s1}"#{s2}")
end

