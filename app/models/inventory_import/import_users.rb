require 'user'

class InventoryImport::ImportUsers
  
  def start(max = 999999)
    connect_dev
    #connect_prod
    
    import_users
    
  end
  
  def import_users
    count = 0
    ignored = 0
    errors = 0
    admins = 0
    InventoryImport::User.all.each do |user|
      count += 1
      if user.geraeteparks_users.count > 0
        if user.benutzerstufe == -3
          u = User.find(:first, :conditions => ['email = ?', user.email])
          u.destroy
        else
          u = User.find_or_create_by_email(:email => user.email, :login => user.login)
          u.lastname = user.nachname
          u.firstname = user.vorname
          u.phone = user.telefon if user.telefon
          if u.save
            if user.benutzerstufe >= 5 
              role = Role.find_by_name('admin')
              u.access_rights << AccessRight.create(:user => u, :role => role)
              admins += 1
            end

            user.geraeteparks_users.each do |geraetepark|
              level = AccessRight::CUSTOMER 
              level = AccessRight::EMPLOYEE if user.benutzerstufe == 2
              level = AccessRight::SPECIAL if user.benutzerstufe == 3
              
              role = Role.find_by_name('customer')
              role = Role.find_by_name('manager') if user.benutzerstufe == 4

              u.access_rights.create(:role => role, :inventory_pool => convert_ip(geraetepark), :level => level)
            end
          else
            errors += 1
            puts "#{user.vorname} #{user.nachname} konnte nicht übernommen werden."
          end
        end
      else
        ignored += 1
      end
    end
    
    puts "Total:   #{count}"
    puts "Ignored: #{ignored}"
    puts "Admins:  #{admins}"
  end

  def convert_ip(ip)
    InventoryPool.find(:first, :conditions => ['name = ?', ip.geraetepark.name])
  end


    def connect_dev
      InventoryImport::Kaufvorgang.establish_connection(leihs_dev)
      InventoryImport::Geraetepark.establish_connection(leihs_dev)
      InventoryImport::Gegenstand.establish_connection(leihs_dev)
      InventoryImport::Paket.establish_connection(leihs_dev)
      InventoryImport::User.establish_connection(leihs_dev)
      InventoryImport::GeraeteparksUser.establish_connection(leihs_dev)
      InventoryImport::ItHelp.establish_connection(it_help_dev)
    end

    def it_help_dev
      {		:adapter => 'mysql',
      		:host => '127.0.0.1',
      		:database => 'ithelp_development',
      		:encoding => 'latin1',
      		:username => 'root',
      		:password => '' }
    end

    def leihs_dev
      {		:adapter => 'mysql',
      		:host => '127.0.0.1',
      		:database => 'rails_leihs_dev',
      		:encoding => 'utf8',
      		:username => 'root',
      		:password => '' }
    end

    def connect_prod
      
        InventoryImport::Kaufvorgang.establish_connection(leihs_prod)
        InventoryImport::Geraetepark.establish_connection(leihs_prod)
        InventoryImport::Gegenstand.establish_connection(leihs_prod)
        InventoryImport::Paket.establish_connection(leihs_prod)
        InventoryImport::User.establish_connection(leihs_prod)
        InventoryImport::GeraeteparksUser.establish_connection(leihs_prod)
        InventoryImport::ItHelp.establish_connection(it_help_prod)
    end
    
    def it_help_prod
      	{ :adapter => 'mysql',
      		:host => '195.176.254.49',
      		:database => 'ithelp_alt',
      		:encoding => 'utf8',
      		:username => 'helpread',
      		:password => '2read.0nly!' }
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
