# encoding: utf-8
# This is to be run from the Rails console using require:
# rails c
# require 'doc/other/csv_import_of_items'

import_file = '/tmp/items.csv'

@failures = 0
@successes = 0

@errorlog = File.open('/tmp/import_errors.txt', 'w+')

items_to_import = CSV.open(import_file, col_sep: ",", headers: true)

def log_error(error, item)
  @errorlog.puts "ERROR: #{error}. --- Item: #{item}"
end

def create_model(item)
  Model.find_or_create_by_product_and_version_and_manufacturer(:product => item['Product'], 
                                                               :version => item['Version'],
                                                               :manufacturer => item['Manufacturer'])
end

def create_location(item)
  b = Building.find_or_create_by_name(item['Building'])
  Location.find_or_create_by_building_id_and_room(:building => b,
                                                      :room => item['Room'])
end

items_to_import.each do |item|
  create_model(item)
  i = Item.new
  i.model = create_model(item)
  i.inventory_code = item['Inventory Code']
  i.name = item['Name']
  i.description = item['Description']
  i.location = create_location(item)

  # Inventory relevance
  i.is_inventory_relevant = true

  # Borrowability
  i.is_borrowable = false
  i.is_borrowable = true if item['Borrowable'] == '1'

  # Completeness
  i.is_complete = false
  i.is_complete = true if item['Completeness'] == '1'

  # Ownership
  owner_ip = InventoryPool.where(:name => 'Guild Music').first
  i.owner = owner_ip

  # Responsible department
  unless item['Verantwortliche Abteilung'] == 'frei'
    responsible_ip = InventoryPool.where(name: item['Verantwortliche Abteilung']).first
    i.inventory_pool = responsible_ip
  end

  # Building and room
  #building_code = item["Building"].match(/.*\((.*)\)$/)[1]
  b = Building.where(code: 'TONI').first

  room = nil
  room = item['Raum'] unless item['Raum'].blank?
  location = Location.find_or_create({'building_id' => b.id, 'room' => room})
  i.location = location

  # Invoice
  i.invoice_number = item['Invoice Number']
  i.invoice_date = Date.strptime(item['Invoice Date'], '%m/%d/%Y') unless item['Invoice Date'].blank?


  i.responsible = item['Responsible person'] unless item['Responsible person'].blank?
  i.price = item['Initial Price'] unless item['Initial Price'].blank?

  i.last_check = Date.strptime(item['letzte Inventur'], '%m/%d/%Y') unless item['letzte Inventur'].blank?

  # Supplier
  i.supplier = Supplier.where(name: item['Lieferant']).first
  if i.supplier.nil?
    i.supplier = Supplier.create(name: item['Lieferant'])
  end

  # Properties
  i.properties[:anschaffungskategorie] = item['Anschaffungskategorie']
  #i.properties[:reference] = "invoice" if item["Bezug"] == "laufende Rechnung"
  #i.properties[:reference] = "investment" if item["Bezug"] == "Investition"

  puts i


  if i.save
  #  puts "Item imported correctly:"
    @successes += 1
  #  puts i.inspect
  else
    @failures += 1
    @errorlog.puts "Could not import item #{i.inventory_code}. Errors: #{i.errors.full_messages}"
  end

end

puts '-----------------------------------------'
puts 'DONE'
puts "#{@successes} successes, #{@failures} failures"
puts '-----------------------------------------'


@errorlog.close
