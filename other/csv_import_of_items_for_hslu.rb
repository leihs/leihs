# This is to be run from the Rails console using require:
# ./script/console
# require 'doc/csv_import_of_items'


require 'faster_csv'
@failures = 0
@successes = 0

def create_item(model_name, inventory_code, serial_number, manufacturer, 
                category, accessory_string, note, building_string, room_string, owner, inventory_pool)
  

  if model_name.blank?
    puts "Can't create item with a blank name."
  else

    m = Model.find_by_name(model_name)
    if m.nil?
      m = create_model(model_name, category, manufacturer, accessory_string)
    end
   
    if owner
      owner_ip = InventoryPool.find_or_create_by_name(owner)
    end
    if inventory_pool
      ip = InventoryPool.find_or_create_by_name(inventory_pool)
    end

    i = Item.new
    i.model = m
    i.inventory_code = inventory_code
    i.serial_number = serial_number
    i.note = note
    i.is_borrowable = true
    i.is_inventory_relevant = true
    i.owner = owner_ip if owner_ip
    i.inventory_pool = ip if ip
    i.location = create_location(building_string, room_string)
    
    if i.save
      puts "Item imported correctly:"
      @successes += 1
      puts i.inspect
    else
      @failures += 1
      puts "Could not import item #{inventory_code}"
    end
    
    puts "-----------------------------------------"
    puts "DONE"
    puts "#{@successes} successes, #{@failures} failures"
    puts "-----------------------------------------"
  end  
end

def create_model(name, category, manufacturer, accessory_string)
  m = Model.create(:name => name, :manufacturer => manufacturer)

  unless category.blank?
    category.split("|").each do |cat_string|
      unless cat_string.blank?
        c = Category.find_or_create_by_name(cat_string)
        m.categories << c
      end
    end
  end
  
  unless accessory_string.blank?  
    accessory_string.split(",").each do |string|
      acc = Accessory.create(:name => string.strip)
      m.accessories << acc
    end
  end
  
  m.save

  return m
end


def create_location(building_string, room_string)

  b = Building.find(:first, :conditions => {:name => building_string})
  unless b
    b = Building.create(:name => building_string)
  end

  l = Location.find(:first, :conditions => {:building_id => b.id, :room => room_string})

  unless l
    l = Location.create(:building_id => b.id, :room => room_string)
  end

  return l
end


#inventory_code;inventory_pool;owner;serial_number;model_name;categories;supplier;model_manufacturer;location;note

#def create_item(model_name, inventory_code, serial_number, manufacturer, 
#                category, accessory_string, note, building_string, room_string)
# CSV fields:
# 0: inventory_code
# 1: inventory_pool
# 2: owner.
# 3: serial_number
# 4: model_name
# 5: categories
# 6: supplier
# 7: model_manufacturer
# 8: location
# 9: note

def run_import(path)
  #lines_to_import = File.open(path).readlines
  lines_to_import = FasterCSV.open(path, :col_sep => "\t", :quote_char => "\"", :headers => true) 
  lines_to_import.each do |line|

  item = line
  #  split_line = line.split("\t")
  #  item = {}
  #  item["model_name"] = split_line[4]
  #  item["inventory_code"] = split_line[0]
  #  item["serial_number"] = split_line[3]
  #  item["model_manufacturer"] = split_line[7]
  #  item["category"] = split_line[5]
  #  item["note"] = "" 
  #  item["note"] = split_line[9] if split_line[9]
  #  item["building_string"] = split_line[8]
  #  item["room_string"] = ""
  #  item["owner"] = split_line[2]
  #  item["inventory_pool"] = split_line[1]

    create_item(item["model_name"],
                item["inventory_code"],
                item["serial_number"],
                item["model_manufacturer"],
                item["category"],
                item["note"],
                item["note"],
                item["building_string"],
                item["room_string"],
                item["owner"],
                item["inventory_pool"])
  end
end



