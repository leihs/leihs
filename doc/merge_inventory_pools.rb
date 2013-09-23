
@logfile = File.open("/tmp/switch.log", "w+")
@zhdk = InventoryPool.where(:name => 'ZHdK-Inventar').first
itz = InventoryPool.where(:name => 'IT-Zentrum').first
avz = InventoryPool.where(:name => 'AV-Technik').first

def fill_in_ask(item, ask)
  item.properties[:anschaffungskategorie] = ask
  if item.save
    @logfile.puts "Item #{item.to_s} now has Anschaffungskategorie '#{item.properties[:anschaffungskategorie]}'"
  else
    @logfile.puts "ERROR: Item #{item.to_s} could NOT be set to '#{item.properties[:anschaffungskategorie]}'"
  end
end

def move_to_zhdk(item)
  item.owner = @zhdk

  if item.save
    @logfile.puts "Item #{item.to_s} moved to ZHdK-Inventar"
  else
    @logfile.puts "ERROR: Item #{item.to_s} could NOT be moved to ZHdK-Inventar"
  end
end

itz.own_items.inventory_relevant.each do |item|
  fill_in_ask(item, "IC-Technik/Software")
  move_to_zhdk(item)
end

avz.own_items.inventory_relevant.each do |item|
  fill_in_ask(item, "AV-Technik")
  move_to_zhdk(item)
end


@logfile.close
