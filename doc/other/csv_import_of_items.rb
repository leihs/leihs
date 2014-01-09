# encoding: utf-8
# This is to be run from the Rails console using require:
# rails c
# require 'doc/other/csv_import_of_items'

import_file = "/tmp/items.csv"

@failures = 0
@successes = 0

items_to_import = CSV.open(import_file, :col_sep => "\t", :headers => true)

# CSV fields:
# 0: Bezeichnung
# 1: Inventarnummer
# 2: Seriennummer
# 3: Hersteller
# 4: Typ (= Kategorie)
# 5: Zubehör (comma-separated field)
# 6: Defekt: (-> Notiz)

items_to_import.each do |item|
  i = Item.new
  i.model = Model.find(item["Leihs - Modellnummer"])
  i.inventory_code = item["Inv-Code:"]
  i.serial_number = item["Seriennummer"]
  i.note = item["Notitz"] # That typo is in the original CSV file already

  # Inventory relevance
  i.is_inventory_relevant = false
  i.is_inventory_relevant = true if item["Inventarrelevant:"] == "JA"

  # Borrowability
  i.is_borrowable = false

  # Ownership
  owner_ip = InventoryPool.where(:name => item["Besitzer"]).first
  i.owner = owner_ip

  # Responsible department
  responsible_ip = InventoryPool.where(:name => item["Verantwortliche Abteilung"]).first
  i.inventory_pool = responsible_ip

  # Building and room
  building_code = item["Gebäude"].match(/.*\((.*)\)$/)[1]
  b = Building.where(:code => building_code).first
  room = nil
  room = item["Raum"] unless item["Raum"].blank?
  i.location = Location.find_or_create({:building_id => b.code, :room => room})

  # Invoice
  i.invoice_number = item["Rechungsnummer"]
  i.invoice_date = Date.strptime(item["Rechnungsdatum"], "%m/%d/%Y") unless item["Rechnungsdatum"].blank?

  i.last_check = Date.strptime(item["letzte Inventur"], "%m/%d/%Y") unless item["letzte Inventur"].blank?

  # Supplier
  i.supplier = Supplier.where(:name => item["Lieferant"]).first
  if i.supplier.nil?
    i.supplier = Supplier.create(:name => item["Lieferant"])
  end

  # Properties
  i.properties[:anschaffungskategorie] = item["Anschaffungskategorie"]
  i.properties[:reference] = "invoice" if item["Bezug"] == "laufende Rechnung"
  i.properties[:reference] = "investment" if item["Bezug"] == "Investition"

  puts i


  #if i.save
  #  puts "Item imported correctly:"
  #  @successes += 1
  #  puts i.inspect
  #else
  #  @failures += 1
  #  puts "Could not import item #{inventory_code}"
  #end

end

puts "-----------------------------------------"
puts "DONE"
puts "#{@successes} successes, #{@failures} failures"
puts "-----------------------------------------"
