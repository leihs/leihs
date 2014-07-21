# encoding: utf-8
# This is to be run from the Rails console using require:
# rails c
# require 'doc/other/csv_import_of_items'

import_file = "/tmp/items.csv"

@failures = 0
@successes = 0

@errorlog = File.open("/tmp/import_errors.txt", "w+")

items_to_import = CSV.open(import_file, :col_sep => "\t", :headers => true)

def log_error(error, item)
  @errorlog.puts "ERROR: #{error}. --- Item: #{item}"
end

def validate_item(item)
  errors = false

  begin
    Model.where(:product => item["Model"]).first
  rescue
    errors = true
    log_error "Model '#{item["Model"]}' not found.", item
  end

  if item["Responsible department"].blank?
    errors = true
    log_error "Responsible department is blank", item
  else
    responsible_ip = InventoryPool.where(:name => item["Responsible department"]).first
    if responsible_ip.nil?
      errors = true
      log_error "Responsible inventory pool '#{item["Responsible department"]}' does not exist", item
    end
  end

  if item["Owner"].blank?
    errors = true
    log_error "Owner is blank", item
  else
    owner_ip = InventoryPool.where(:name => item["Owner"]).first
    if owner_ip.nil?
      errors = true
      log_error "Owner '#{item["Owner"]}' does not exist", item
    end
  end


  if errors
    return false
  else
    return true
  end
end

items_to_import.each do |item|
  next if not validate_item(item)
  i = Item.new
  i.model = Model.where(:product => item["Model"]).first
  #i.inventory_code = item["Inv-Code:"]
  i.serial_number = item["Serial Number"]
  i.note = item["Note"]

  # Inventory relevance
  i.is_inventory_relevant = false
  i.is_inventory_relevant = true if item["Relevant for inventory"] == "true"

  # Borrowability
  i.is_borrowable = false

  # Ownership
  owner_ip = InventoryPool.where(:name => item["Owner"]).first
  i.owner = owner_ip

  # Responsible department
  unless item["Responsible department"] == "frei"
    responsible_ip = InventoryPool.where(:name => item["Responsible department"]).first
    i.inventory_pool = responsible_ip
  end

  # Building and room
  building_code = item["Building"].match(/.*\((.*)\)$/)[1]
  b = Building.where(:code => building_code).first

  room = nil
  #room = item["Raum"] unless item["Raum"].blank?
  location = Location.find_or_create({"building_id" => b.id, "room" => room})
  i.location = location

  # Invoice
  i.invoice_number = item["Invoice Number"]
  i.invoice_date = Date.strptime(item["Invoice Date"], "%m/%d/%Y") unless item["Invoice Date"].blank?


  i.responsible = item["Responsible person"] unless item["Responsible person"].blank?
  i.price = item["Initial Price"] unless item["Initial Price"].blank?

  #i.last_check = Date.strptime(item["letzte Inventur"], "%m/%d/%Y") unless item["letzte Inventur"].blank?

  # Supplier
  #i.supplier = Supplier.where(:name => item["Lieferant"]).first
  #if i.supplier.nil?
  #  i.supplier = Supplier.create(:name => item["Lieferant"])
  #end

  # Properties
  #i.properties[:anschaffungskategorie] = item["Anschaffungskategorie"]
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

puts "-----------------------------------------"
puts "DONE"
puts "#{@successes} successes, #{@failures} failures"
puts "-----------------------------------------"


@errorlog.close
