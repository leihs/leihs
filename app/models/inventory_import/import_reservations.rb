require 'user'

class InventoryImport::ImportReservations

  def start(pool)
    
    connect_dev
    #connect_prod
    conditions = (pool == 0) ? ['status >=2'] : ['status >= 0 and geraetepark_id = ?', pool]
    reservations = InventoryImport::Reservation.find(:all, :conditions => conditions)
    
    puts "#{reservations.size} reservations will be imported"
    orders = 0
    contracts = 0
    reservations.each do |reservation|
      if reservation.status < 3
        import_as_order(reservation)
        orders += 1
      else
        import_as_contract(reservation)
        contracts += 1
      end
    end
    
    puts "#{orders} Orders"
    puts "#{contracts} Contracts"
  end

  def import_as_order(reservation)
    
    user = User.find_by_login(reservation.user.login)
    if user.nil?
      puts "#{reservation.user.login} not found. Not importing order"
      return
    end
    
    o = Order.create(:user => user,
                  :purpose => reservation.zweck,
                  :inventory_pool => get_inventory_pool(reservation.geraetepark.name),
                  :status_const => Order::SUBMITTED)

    o.created_at = reservation.created_at
    o.save
          
    reservation.pakets.each do |paket|
      paket.gegenstands.each do |gegenstand|
        item = Item.find(:first, :conditions => ['inventory_code = ?', "#{gegenstand.inventar_abteilung}#{gegenstand.original_id}"])
        if item
          line = OrderLine.new(:order => o,
                                :model => item.model,
                                :quantity => 1,
                                :start_date => reservation.startdatum,
                                :end_date => reservation.enddatum,
                                :inventory_pool => get_inventory_pool(reservation.geraetepark.name))
            unless line.save
              puts "-------> Line not saved (Order: #{o.id} User: #{o.user.id} Item: #{item.inventory_code})"
              puts "#{line.errors.full_messages}"
            end
        else
          puts "#{gegenstand.inventar_abteilung}#{gegenstand.original_id} not found  (Contract: #{o.id} User: #{o.user.id})"
        end
      end
    end
    
    puts "Approving: " + o.approve("Approved in leihs 1", false).to_s if reservation.status == 2
    
  end
  
#  def login_for(id)
#    InventoryImport::User.find(id).login
#  end
  
  def import_as_contract(reservation)
    
    user = User.find_by_login(reservation.user.login)
    if user.nil?
      puts "#{reservation.user.login} not found. Not importing contract."
      return
    end
    
    c = Contract.create(:user => user,
                  :purpose => reservation.zweck,
                  :inventory_pool => get_inventory_pool(reservation.geraetepark.name),
                  :status_const => Contract::SIGNED)
    
    c.created_at = reservation.created_at
    c.save
    
    reservation.pakets.each do |paket|
      paket.gegenstands.each do |gegenstand|
        
        item = Item.find(:first, :conditions => ['inventory_code = ?', "#{gegenstand.inventar_abteilung}#{gegenstand.original_id}"])
        if item
          line = ContractLine.new(:contract => c,
                          :item => item,
                          :model => item.model,
                          :start_date => reservation.startdatum,
                          :end_date => reservation.enddatum)
          unless line.save
            puts "-------> Line not saved (Contract: #{c.id} User: #{c.user.id} Item: #{item.inventory_code})"
            puts "#{line.errors.full_messages}"
          end
        else
          puts "#{gegenstand.inventar_abteilung}#{gegenstand.original_id} not found  (Contract: #{c.id} User: #{c.user.id})"
        end
      end
    end    
    
  end
  
  def get_inventory_pool(inv_abt)
    o = InventoryPool.find(:first, :conditions => ['name = ?', inv_abt])
    o = InventoryPool.find(:first, :conditions => ['name = ?', use_new_name_for(inv_abt)]) unless o
    o
  rescue
    puts "InventoryPool '#{inv_abt}' not found."
    nil
  end
  
  def use_new_name_for(inv_abt)
    return "VMK" if inv_abt.upcase == "SNM" 
    return "VMK" if inv_abt.upcase == "VNM"
    return "VIAD" if inv_abt.upcase == "IAD"
    inv_abt
  end
  
  def connect_dev
    InventoryImport::Reservation.establish_connection(leihs_dev)    
    InventoryImport::Paket.establish_connection(leihs_dev)    
    InventoryImport::Gegenstand.establish_connection(leihs_dev)    
    InventoryImport::Geraetepark.establish_connection(leihs_dev)    
  end
  
  def connect_prod
    InventoryImport::Reservation.establish_connection(leihs_prod)
    InventoryImport::Paket.establish_connection(leihs_prod)
    InventoryImport::Gegenstand.establish_connection(leihs_prod)
    InventoryImport::Geraetepark.establish_connection(leihs_prod)
  end
  
  def leihs_dev
    {		:adapter => 'mysql',
    		:host => '127.0.0.1',
    		:database => 'rails_leihs_dev',
    		:encoding => 'utf8',
    		:username => 'root',
    		:password => '' }
  end
  
  def leihs_prod
     {  :adapter => 'mysql',
    		:host => '195.176.254.49',
    		:database => 'rails_leihs',
    		:encoding => 'utf8',
    		:username => 'leihsread',
    		:password => '2read.0nly!' }
  end

end