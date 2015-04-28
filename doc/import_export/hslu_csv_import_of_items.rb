# This is to be run from the Rails console using require:
# ./script/console
# require 'doc/csv_import_of_items'




#import_file = "/tmp/items.csv"
import_file = '/tmp/items2.csv'


@failures = 0
@successes = 0

def create_item(model_name, inventory_code, serial_number, manufacturer, category, accessory_string, note, price, invoice_date)
  
  m = Model.find_by_product(model_name)
  if m.nil?
    m = create_model(model_name, category, manufacturer, accessory_string)    
  end
  
  ip = InventoryPool.find_or_create_by_name('HSLU')
  
  i = Item.new
  i.model = m
  i.inventory_code = inventory_code
  i.serial_number = serial_number
  i.note = note
  i.owner = ip
  i.is_borrowable = true
  i.is_inventory_relevant = true
  i.inventory_pool = ip
  i.price = price
  i.invoice_date = invoice_date
  
  if i.save
    puts 'Item imported correctly:'
    @successes += 1
    puts i.inspect
  else
    @failures += 1
    puts "Could not import item #{inventory_code}"
    puts i.errors.full_messages
    puts i.inspect
  end
  
  puts '-----------------------------------------'
  puts 'DONE'
  puts "#{@successes} successes, #{@failures} failures"
  puts '-----------------------------------------'
  
end

def create_model(name, category, manufacturer, accessory_string)
  
  puts "creating model: #{name}, #{category}, #{manufacturer}, #{accessory_string}"
  
  if category.blank?
    c = Category.find_or_create_by_name('Keine Kategorie')
  else  
    c = Category.find_or_create_by_name(category)
  end
  
  m = Model.create(name: name, manufacturer: manufacturer)
  m.categories << c

  unless accessory_string.blank?  
    accessory_string.split('-').each do |string|
      unless string.blank?
        acc = Accessory.create(name: string.strip)
        m.accessories << acc
      end
    end
  end

  m.save
  return m
end

require 'csv'
items_to_import = CSV.open(import_file, headers: true)

# CSV fields:
# 0: Bezeichnung
# 1: Inventarnummer
# 2: Seriennummer
# 3: Hersteller
# 4: Typ (= Kategorie)
# 5: Zubehör (comma-separated field)
# 6: Defekt: (-> Notiz)

items_to_import.each do |item|
  model_name = "#{item["Gerätebezeichnung"]} #{item["Typenbezeichnung"]}"
  
  if model_name.blank?
    puts 'Skipping item with blank model name.'
    next
  end
  
  note = "#{item["Referenzdatei Inventar"]} #{item["Fehler Reparatur"]}"
  
  price = item['Preis_Neu'].to_f
  puts "price parsed to #{price}"
  # The purchase dates in the source file are only years, but Date.parse can't handle that,
  # so we add -01-01 to force to January 1.
  invoice_date = Date.parse("#{item['Kaufdatum'].strip}-01-01") unless item['Kaufdatum'].blank?
  puts "purchase date parsed to #{invoice_date}"
  
  create_item(model_name, 
              item['Inventarnummer_ID'],
              item['Seriennummer'],
              item['Marke'],
              item['Gerätekategorie'],
              item['Zubehör'],
              note,
              price,
              invoice_date)
end



