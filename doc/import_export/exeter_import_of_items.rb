# encoding: utf-8
# This is to be run from the Rails console using require:
# rails c
# require 'doc/other/csv_import_of_items'

import_file = '/tmp/items.csv'

@failures = 0
@successes = 0

@errorlog = File.open('/tmp/import_errors.txt', 'w+')
@itemlog = File.open('/tmp/import_items.txt', 'w+')

items_to_import = CSV.open(import_file, col_sep: "\t", headers: true)

def log_error(error, item)
  @errorlog.puts "ERROR: #{error}. --- Item: #{item}"
end

def create_model(item)
  m = Model.where(:product => item['Product'], 
                  :version => item['Version'],
                  :manufacturer => item['Manufacturer']).first_or_create
  m.description = item['Description'] if item['Description']
  if m.save
    return m
  else
    @errorlog.puts "Could not create model for item #{item}, #{m.errors.full_messages}"
  end
end

def create_location(item)
  b = Building.where(:name => item['Building']).first_or_create
  Location.where(:building => b,
                 :room => item['Room']).first_or_create
end

items_to_import.each do |item|
  create_model(item)
  i = Item.new
  model = create_model(item)
  if model.nil? or model == false
    @failures += 1
    next
  end
  i.model = create_model(item)
  
  category = Category.where(:name => item['Categories']).first_or_create
  unless i.model.categories.include?(category)
    i.model.categories << category
  end

  i.inventory_code = item['Inventory Code']
  i.name = item['Name']
  i.location = create_location(item)

  # Inventory relevance
  i.is_inventory_relevant = true

  # Borrowability
  i.is_borrowable = false
  i.is_borrowable = true if item['Borrowable'] == '1'

  # Completeness
  i.is_incomplete = true
  i.is_incomplete = false if item['Completeness'] == '1'

  # Ownership
  owner_ip = InventoryPool.where(:name => 'Guild Music').first
  i.owner = owner_ip
  i.inventory_pool = owner_ip


  # Responsible department
  #unless item['Verantwortliche Abteilung'] == 'frei'
  #  responsible_ip = InventoryPool.where(name: item['Verantwortliche Abteilung']).first
  #  i.inventory_pool = responsible_ip
  #end

  if i.save
  #  puts "Item imported correctly:"
    @successes += 1
    @itemlog.puts(i.inspect)
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
@itemlog.close
