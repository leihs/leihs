
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
