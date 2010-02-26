# sql for leihs1:
#
# select us.nachname, us.vorname, count(res.id)
# 
# from reservations as res
# left join pakets_reservations as pr on res.id = pr.reservation_id
# left join users as us on res.user_id = us.id
# left join pakets as p on pr.paket_id = p.id
# 
# where 
#   ( 
#     YEAR(startdatum) = 2009 or YEAR(enddatum) = 2009
#     and res.geraetepark_id = 4
#   )
# 
# group by res.user_id



def csv_counts_for_year(year)
  csv_data = Array.new
  users = User.all

  users.each do |us|
    items = 0
    
    if us.contracts.count > 0
      
      interesting_contracts = us.contracts.select{|c|
        c.created_at.year == year
        c.lines.count > 0
        c.inventory_pool_id = 4
      }
      contract_count = interesting_contracts.size.to_i
      
      interesting_contracts.each do |co|
        @line_count = co.lines.count
        co.lines.each do |cl|
          items += cl.quantity            
        end
      end
      csv_data << [us.lastname, us.firstname, contract_count, items, @line_count]
    end
    
  end
  return csv_data
end


def save_to_file(path, data)
  require 'faster_csv'
  FasterCSV.open(path, "w", {:headers => true, :col_sep => ';', }) do |csv|
    csv << ["Nachname", "Vorname", "Vertraege", "Geliehene Geraete"]
    data.each do |item|
      csv << item
    end
  end
end