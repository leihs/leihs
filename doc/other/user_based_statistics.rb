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




def csv_counts_for_year(year)
  csv_data = Array.new
  users = User.all

  users.each do |us|
    items = 0
    
    if us.reservations_bundles.count > 0
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


def save_to_file(path, data)
  
  require 'csv'
  CSV.open(path, "w", {:headers => true, :col_sep => ';', }) do |csv|
    csv << ["Nachname", "Vorname", "Vertraege", "Geliehene Geraete"]
    data.each do |item|
      csv << item
    end
  end
end
