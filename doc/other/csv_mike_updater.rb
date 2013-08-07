

require 'rubygems'



unfound = []

require 'csv'
CSV.foreach("/tmp/mike_update.csv", :col_sep => ";", :headers => :first_row) do |row|

  owner = row[0]
  number = row[1]
  ip = row[6]
  date = row[8]

  parsed_date = Date.strptime(date, '%m/%d/%Y') 
  ownerpool = InventoryPool.find_by_name(owner)
  responsible = InventoryPool.find_by_name(ip)

  if ownerpool.nil?
    puts "---------> CANNOT FIND OWNER IP: " + owner
    unfound << owner
  end

  if responsible.nil?
    puts "---------> CANNOT FIND RESP IP: " + ip
    unfound << ip
  end

  puts "Trying item no. " + number
  item = Item.find_by_inventory_code(number)
  puts "Setting new values: "
  #puts "Owner: " + ownerpool.to_s + " (Original: " + item.owner.to_s  + ")"
  puts "Responsible: " + responsible.to_s + " (Original: " + item.inventory_pool.to_s + ")"
  #puts "Invoice date: " + parsed_date.to_s + " (Original: " + item.invoice_date.to_s  + ")"
  #item.owner = ownerpool
  item.inventory_pool = responsible
  #item.invoice_date = parsed_date
  item.save
  puts "-----------------"

end

unfound = unfound.uniq

