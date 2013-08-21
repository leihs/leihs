

# Use a tab-separated file for this.
#
# Column 0: Inventory code
# Column 1: Null: Don't do anything
#           String: Change the owner to this inventory pool
# Column 2: Null: Don't do anything
#           String 'NEIN': Change 'inventory_relevant' to 'false' for this item

@logfile = File.open("/tmp/switch_log.log", "w")

def update_item(data)

  item = Item.where(:inventory_code => data[:inventory_code]).first
  if item
    relevant = true
    owner = item.owner

    relevant = false if data[:new_relevance] == 'NEIN'
    if data[:new_owner] and data[:new_owner].is_a?(String)
      new_owner = InventoryPool.where(:name => data[:new_owner]).first
      owner = new_owner unless new_owner.nil?
    end

    item.is_inventory_relevant = relevant
    item.owner = owner

    #@logfile.puts "Would set: #{item.inventory_code.to_s}: #{relevant}, #{owner.to_s}"
    if item.save
      @logfile.puts "Item #{data[:inventory_code]} updated: owner == #{item.owner.to_s}, inventory relevant: #{item.is_inventory_relevant}"
    else
      @logfile.puts "ERR: Item #{data[:inventory_code]} could not be updated. #{item.errors.full_messages}"
    end

  else
    @logfile.puts "WARNING: Item with code #{data[:inventory_code]} not found. Skipping."
  end
end

csv = File.open("/tmp/vorfusion.csv", "r")

csv.readlines.each do |line|
  array = line.strip.split("\t")
  update_item({:inventory_code => array[0],
               :new_owner => array[1],
               :new_relevance => array[2]})
end


@logfile.close
