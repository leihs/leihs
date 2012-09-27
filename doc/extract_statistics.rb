
def statistics_for_year(ip, year = 2011)
  order_lines = ip.order_lines.find(:all, :conditions => "start_date BETWEEN DATE('#{year}-01-01') AND DATE('#{year}-12-31')")
  orders = order_lines.collect(&:order)

  contract_lines = ip.contract_lines.find(:all, :conditions => "start_date BETWEEN DATE('#{year}-01-01') AND DATE('#{year}-12-31')")
  contracts = contract_lines.collect(&:contract)

  item_count = 0
  contracts.each do |c|
    c.lines.each do |l|
      item_count += l.quantity
    end
  end

  statistics = {:pool => ip, :orders => orders, :contracts => contracts, :item_count => item_count}
  return statistics
end

def pretty_print_statistics(stats, year = 2011)
  pad_to = 30
  pool = stats[:pool]
  orders = stats[:orders]
  contracts = stats[:contracts]
  item_count = stats[:item_count]

  if pool.to_s.length < (pad_to - 1)
    # +2 because of the ": "
    padded_pool = "#{pool.to_s}: #{" " * (pad_to - (pool.to_s.length + 2))}"
    padded_short_pool = "#{pool.shortname.to_s}#{" " * (pad_to - pool.shortname.to_s.length)}"
  else
    padded_pool = "#{pool.to_s[0..(pad_to - 3)]}: "
  end
  padded_short_pool = "#{pool.shortname.to_s}#{" " * (pad_to - pool.shortname.to_s.length)}"

  f = File.open("/tmp/stats_#{year}.txt", "a")
  f.puts "#{padded_pool}#{orders.count} Bestellungen, #{contracts.count} Verträge"
  f.puts "#{padded_short_pool}#{item_count} Gegenstände in Verträgen"
  f.puts "\n"
  f.close
end

def csv_print_header(year = 2011)
  f = File.open("/tmp/stats_#{year}.csv", "w")
  f.puts("pool,orders,contracts,items\n")
  f.close
end

def csv_print_statistics(stats, year = 2011)
  pool = stats[:pool]
  orders = stats[:orders]
  contracts = stats[:contracts]
  item_count = stats[:item_count]

  f = File.open("/tmp/stats_#{year}.csv", "a")
  f.puts("#{pool.to_s} (#{pool.shortname}),#{orders.count},#{contracts.count},#{item_count}\n")
  f.close
end


pools = InventoryPool.all(:order => :name)
[2007, 2008, 2009, 2010, 2011].each do |year|
  csv_print_header(year)
  pools.each do |ip|
    stats = statistics_for_year(ip, year)
    pretty_print_statistics(stats, year)
    csv_print_statistics(stats,year)
  end
end



def contract_line_analysis_for_item(item, year = nil)
  item_total_days = 0
  item_handovers = 0
  lines_text = ""

  if year == nil
    lines = item.contract_lines
  else
    lines = item.contract_lines.find(:all, :conditions => "start_date > '#{year}-01-01' AND start_date < '#{year}-12-31'")
  end

  lines.each do |cl|
    unless cl.returned_date.nil?
      days = (cl.returned_date - cl.start_date).to_i
      item_handovers += 1
      item_total_days += days 
      lines_text += ",,,#{cl.start_date.to_s},#{cl.returned_date.to_s},1,#{days}\n"
    end
  end

  header_text = "\"#{item.inventory_code}\",\"#{item.inventory_pool}\",\"#{item.model.name.gsub(34.chr,'')}\",,,#{item_handovers},#{item_total_days}\n"
  return header_text + lines_text
end

def movements_by_day(inventory_pool, year)
  lines_text = ""
  start_day = Date.parse("#{year}-01-01")
  end_day = Date.parse("#{year}-12-31")

  header_text = "\"#{inventory_pool}\",day,incoming,outgoing,total_out\n"
  start_day.upto(end_day) do |day|
    outgoing = ContractLine.by_inventory_pool(inventory_pool).find(:all, :conditions => {:start_date => day})
    incoming = ContractLine.by_inventory_pool(inventory_pool).find(:all, :conditions => {:returned_date => day})
    unreturned = ContractLine.by_inventory_pool(inventory_pool).find(:all, 
                                                                     :conditions => "start_date < '#{day.to_s}' AND end_date <= '#{day.to_s}' AND returned_date <= '#{day.to_s}'")

    lines_text += ",#{day.to_s},#{incoming.count},#{outgoing.count},#{unreturned.count}\n"
  end
  return header_text + lines_text
end


def analyze_hkb
  
  handovers = File.open("/tmp/handovers.csv","w")
  Item.all.each do |item|
    handovers.puts(contract_line_analysis_for_item(item, 2010))
  end
  handovers.close
 
  ip = InventoryPool.find(4) 
 
  movements = File.open("/tmp/movements.csv","w")
  movements.puts(movements_by_day(ip, 2011))
  movements.close

end


