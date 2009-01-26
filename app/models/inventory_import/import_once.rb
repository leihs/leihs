require 'user'

class InventoryImport::ImportOnce
  
  def start(max = 999999)
    #connect_dev
    connect_prod
    
    import_items(max)
    import_users
    
  end

  def import_items(max)
    inventar = InventoryImport::Gegenstand.find(:all, :conditions => "original_id is null")
    count = 0
    successfull = 0
    
    inventar.each do |gegenstand|
      
     # puts "Found: #{item.Inv_Serienr} - #{item.Art_Bezeichnung} = #{gegenstand.modellbezeichnung}"
      attributes = {
        :name => gegenstand.modellbezeichnung,
        :manufacturer => gegenstand.hersteller,
        :description => gegenstand.paket.nil? ? "" : gegenstand.paket.hinweise,
        :internal_description => gegenstand.paket.nil? ? "" : gegenstand.paket.hinweise_ausleih,
        :rental_price => gegenstand.paket.nil? ? 0 : gegenstand.paket.price,
        :info_url => gegenstand.info_url
      }
      model = Model.find_or_create_by_name attributes
      
      add_picture(model, gegenstand.bild_url) if gegenstand.bild_url and not gegenstand.bild_url.blank? and model.images.size == 0

      cat_name = gegenstand.paket.art if gegenstand.paket
      cat_name ||= gegenstand.art 
      cat_name ||= "Andere Hardware"
      category = Category.find_or_create_by_name :name => cat_name
      category.models << model unless category.models.include?(model) # OPTIMIZE 13** avoid condition, check uniqueness on ModelLink
      
      location = get_location(gegenstand)
      if location.nil?
        puts "Ignoring item with id: #{gegenstand.id} because I couldn't figure out to which inventory pool it belongs."
      else
        item_attributes = {
          :inventory_code => (gegenstand.inventar_abteilung + gegenstand.id.to_s),
          :serial_number => gegenstand.seriennr,
          :model => model,
          :location => get_location(gegenstand).main_location,
          :owner => get_owner(gegenstand.inventar_abteilung),
          :last_check => gegenstand.letzte_pruefung,
          :retired => gegenstand.ausmusterdatum,
          :retired_reason => gegenstand.ausmustergrund,
          :invoice_number => gegenstand.kaufvorgang.nil? ? '' : gegenstand.kaufvorgang.rechnungsnr,
          :invoice_date => gegenstand.kaufvorgang.nil? ? nil : gegenstand.kaufvorgang.kaufdatum,
          :is_incomplete => gegenstand.paket.nil? ? false : (gegenstand.paket.status == 0),
          :is_broken => gegenstand.paket.nil? ? false : (gegenstand.paket.status == -2),
          :is_borrowable => gegenstand.ausleihbar?, 
					:price => (gegenstand.kaufvorgang.nil? or gegenstand.kaufvorgang.kaufpreis.nil?) ? 0 : gegenstand.kaufvorgang.kaufpreis / 100
        }
        item = Item.find_or_create_by_inventory_code item_attributes
        successfull += 1
      end
      count += 1
      break if count == max
    end
    puts "--------------"
    puts "Total: #{count}"
    puts "Successfull: #{successfull}"
    puts "Not so successfull: #{count - successfull}"
    
  end
  
  def get_location(gegenstand)
    if gegenstand.paket
      get_owner(gegenstand.paket.geraetepark.name)
    else
      puts "No Inventorypool found for #{gegenstand.id} - taking owner."
      o = get_owner(gegenstand.inventar_abteilung)
      if o.nil?
        puts "--> Also no owner found..."
      end
      o
    end
  end
  
  def get_owner(inv_abt)
    InventoryPool.find(:first, :conditions => ['name = ?', inv_abt])
  rescue
    puts "InventoryPool '#{inv_abt}' not found."
    nil
  end

  def add_picture(model, url)
    url = url.gsub("hgkz", "zhdk")
    url = URI.parse(url)
    h = Net::HTTP.new(url.host, 80)

    resp, data = h.get(url.path, nil)
    if resp.message == "OK"
      
      File.open("picture.jpg", "w") { |f| f.write(data) }
      image = Image.new(:temp_path => "picture.jpg", :filename => 'picture.jpg', :content_type => 'image/jpg')
      image.model = model
      if not image.save
        puts "Couldn't create file: #{url} for #{model.name}"
      end
    else
      puts "Couldn't download: #{url} (for #{model.name})"
    end
  rescue
    puts "Couldn't append #{url} to #{model.name}"
  end

  def import_users
    count = 0
    ignored = 0
    errors = 0
    admins = 0
    InventoryImport::User.all.each do |user|
      count += 1
      if user.geraeteparks_users.count > 0
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
            level = user.benutzerstufe > 0 and user.benutzerstufe < 4 ? user.benutzerstufe : 1
            role = Role.find_by_name('customer')
            role = Role.find_by_name('manager') if user.benutzerstufe == 4

            u.access_rights << AccessRight.create(:user => u, 
                                                      :role => role,
                                                      :level => level, 
                                                      :inventory_pool => convert_ip(geraetepark))            
          end
        else
          errors += 1
          puts "#{user.vorname} #{user.nachname} konnte nicht übernommen werden."
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
      		:database => 'help',
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
