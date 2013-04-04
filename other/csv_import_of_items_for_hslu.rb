# This is to be run from the Rails console using require:
# ./script/console
# require 'other/csv_import_of_items_for_hslu'
# run_import_with_broken_csv('/tmp/foo.csv')

def create_item(i)
  if i["model_name"].blank?
    puts "Can't create item with a blank model name."
  else

    if i["owner"]
      owner_ip = InventoryPool.find_or_create_by_name(i["owner"])
    end
    if i["inventory_pool"]
      ip = InventoryPool.find_or_create_by_name(i["inventory_pool"])
    end
    if i["supplier"]
      supplier = Supplier.find_or_create_by_name(i["supplier"])
    end

    item = Item.new
    item.model = create_model(i["model_name"], i["category"], i["model_manufacturer"], i["accessory_string"], i["model_description"])
    item.inventory_code = i["inventory_code"]
    item.serial_number = i["serial_number"]
    item.note = i["note"]
    item.is_borrowable = false
    #item.is_borrowable = true if i["inventory_pool"] == i["owner"]
    item.is_borrowable = true if i["is_borrowable"] == "True"
    item.is_inventory_relevant = true
    item.owner = owner_ip if owner_ip
    item.inventory_pool = ip if ip
    item.location = create_location(i["building_string"], i["room_string"], i["shelf_string"])
    item.price = i["price"].to_f
    item.supplier = supplier
    item.last_check = Date.parse(i["inventory_date"]) unless (i["inventory_date"].blank? or i["inventory_date"] == "0")
    item.invoice_date = Date.parse(i["invoice_date"]) unless (i["invoice_date"].blank? or i["invoice_date"] == "0")


    if i["group"] == "Video"
      group = Group.find_or_create_by_name("Video")
      group.inventory_pool = ip
      group.save

      p = Partition.find(:first, :conditions => {:group_id => group, :model_id => item.model, :inventory_pool_id => group.inventory_pool})

      if not p
        p = Partition.new
        p.model = item.model
        p.group = group
        p.inventory_pool = group.inventory_pool
      end

      if p.quantity == nil
        p.quantity = 1
      else
        p.quantity += 1
      end

      unless p.save
        binding.pry
      end
    end

    if item.save
      return true
    else
      return false
    end
  end
end

def create_model(name, category, manufacturer, accessory_string, description)
  m = Model.find_by_name(name)
  if m.nil?
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
      accessory_string.split("|").each do |string|
        unless string.blank?
          string.gsub!(/^\-\ /,"")
          string.gsub!(/^\-/,"")
          unless.string.strip.blank?
            acc = Accessory.create(:name => string.strip)
            m.accessories << acc
          end
        end
      end
    end

    unless description.blank?
      m.description = description
    end

    if m.save == false
      binding.pry
    end

  end
  return m
end


def create_location(building_string, room_string = "", shelf_string = "")
  b = Building.find(:first, :conditions => {:name => building_string})
  unless b
    b = Building.create(:name => building_string)
  end

  l = Location.find(:first, :conditions => {:building_id => b.id, :room => room_string, :shelf => shelf_string})
  unless l
    l = Location.create(:building_id => b.id, :room => room_string, :shelf => shelf_string)
  end

  return l
end

# If you get a broken CSV file (one that does not conform to RFC 4180
# as described here: http://tools.ietf.org/html/rfc4180), you can try
# to brute force your way ahead by using a primitive split on tab separators
# instead of a proper CSV library.
#
# The expected format for the CSV file is (as exported using LibreOffice):
# Field separator: {Tab}
# Text quote character:
#                      ^ nothing, empty, no text separator
#
# You have to prepare the "accessories" field so it does not contain any newlines.
# Separate the accessories with pipes: |

# The header of the example file:
#0	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18
#inventory_code	inventory_pool	owner	serial_number	model_name	categories	supplier	model_manufacturer	note	model_description	accessories	invoice_date	price	group	is_borrowable	building	room	shelf	inventory_date

def run_import_with_broken_csv(path)
  report = ""
  successes = 0
  failures = 0

  lines_to_import = File.open(path).readlines
  lines_to_import.each do |line|

    split_line = line.split("\t")
    item = {}
    item["inventory_code"] = split_line[0]
    item["inventory_pool"] = split_line[1]
    item["owner"] = split_line[2]
    item["serial_number"] = split_line[3]
    item["model_name"] = split_line[4]
    item["category"] = split_line[5]
    item["supplier"] = split_line[6]
    item["model_manufacturer"] = split_line[7]
    item["note"] = split_line[8]
    item["model_description"] = split_line[9]
    item["accessory_string"] = split_line[10]
    item["invoice_date"] = split_line[11]
    item["price"] = split_line[12]
    item["group"] = split_line[13]
    item["is_borrowable"] = split_line[14]
    item["building_string"] = split_line[15]
    item["room_string"] = split_line[16]
    item["shelf_string"] = split_line[17]
    item["inventory_date"] = split_line[18].strip # Need to strip the \n from the last element on a line

    puts "Trying to create item: #{pretty_print_item_hash(item)}"

    if create_item(item)
      report += "Item imported correctly: #{pretty_print_item_hash(item)}\n"
      successes += 1
      puts item.inspect
    else
      failures += 1
      report += "Could not import item #{pretty_print_item_hash(item)}\n"
    end
  end

  puts "-----------------------------------------"
  puts "DONE"
  puts "#{successes} successes, #{failures} failures"
  puts "-----------------------------------------"
  puts "#{report}"
  puts "-----------------------------------------"

end

def pretty_print_item_hash(item_hash)
  return "#{item_hash["inventory_code"]}: #{item_hash["model_name"]}"
end
