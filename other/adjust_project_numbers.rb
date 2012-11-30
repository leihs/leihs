
# Works only on Rails 3, Ruby 1.9
require 'csv'

def adjust_from_file(path)
  logfile = File.open("/tmp/import.log", "w")
  CSV.open(path, :col_sep => "\t").each do |csv|
      result = add_project_number_to_item(csv[0], csv[1])
      if result == true 
        msg = "Inventory code: #{csv[0]}, project number: #{csv[1]}" 
        puts msg
        logfile.puts msg
      else
        msg = "Error processing: #{csv[0]}. Error was: #{result.to_s}"
        puts msg
        logfile.puts msg
    end
  end
  logfile.close
end


def add_project_number_to_item(inventory_code, project_number)
  inventory_code = inventory_code.split("/")[0] # Split package inventory codes, which are foo/bar

  item = Item.where(:inventory_code => inventory_code).first
  if item
    item.properties[:project_number] = project_number
    item.properties[:reference] = "investment"
    if item.save
      return true
    else
      return item.errors.full_messages
    end
  else
    return "Item #{inventory_code} not found"
  end
end
