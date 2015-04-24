# sql for leihs1:


# select res.user_id, users.vorname, users.nachname, users.email, res.id, count(pak_res.paket_id) from reservations as res, pakets_reservations as pak_res, users
# 
# where 
#   ( 
# pak_res.reservation_id = res.id and
# res.user_id = users.id and
# res.geraetepark_id = 1
# 
# and  (YEAR(startdatum) = 2009 or YEAR(enddatum) = 2009)
#   )
# 
# group by res.id, res.user_id order by res.user_id



def contracts_for(options = {:inventory_pool_id => 1, :year => 2010})

  return Contract.find(:all, 
                       :conditions => {:created_at => Date.parse("#{options[:year]}-01-01")..Date.parse("#{options[:year]}-12-31"),
                       :inventory_pool_id => options[:inventory_pool_id]})
end

def yearly_contracts(year)
  # header to use here:
  # header = ["Geraetepark", "Jahr", "Vertraege", "Gegenstaende"]

  data = []
  InventoryPool.all.each do |ip|
    ip_item_total = 0
    ip_contract_total = 0
    contracts = contracts_for(:inventory_pool_id => ip.id, :year => year)
    contracts.each do |c|
      ip_contract_total += 1
      c.reservations.each do |l|
        ip_item_total += l.quantity
      end
    end

    data << [ip.to_s, year, ip_contract_total, ip_item_total]
  end
  return data
end

def dump_all
  [2007, 2008, 2009, 2010, 2011].each do |year|
    data = yearly_contracts(year)
    header = ["Geraetepark", "Jahr", "Vertraege", "Gegenstaende"]
    save_to_file("/tmp/big_stats2.csv", data, header)
  end
end

def csv_counts_for_year_by_user(year)
  csv_data = Array.new
  users = User.all

  users.each do |us|
    items = 0
    
    if us.reservations_bundles.exists?
      interesting_contracts = us.reservations_bundles.find(:all, :conditions => ['YEAR(created_at) = ? AND inventory_pool_id = ?', year, 1])
      contract_count = interesting_contracts.size.to_i
      
      interesting_contracts.each do |co|
        @line_count = co.reservations.count
        co.reservations.each do |cl|
          items += cl.quantity            
        end
      end
      csv_data << [us.lastname, us.firstname, contract_count, items, @line_count]
    end
    
  end
  return csv_data
end


def save_to_file(path, data, header = nil)
  if header == nil
    header = ["Nachname", "Vorname", "Vertraege", "Geliehene Geraete"]
  end
  
  require 'csv'
  CSV.open(path, "a", {:headers => true, :col_sep => ';', }) do |csv|
    csv << header
    data.each do |item|
      csv << item
    end
  end
end
