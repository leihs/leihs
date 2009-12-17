require 'net/http'
require 'uri'

class InventoryImport::Importer
  
  attr_accessor :messages
  
  def start(max = 999999)
    connect_dev
    #connect_prod
    self.messages = []
    inventar = InventoryImport::ItHelp.find(:all,	:order => 'Inv_Serienr')
    count = 0
    
    import_inventory_pools

    inventar.each do |item|
      gegenstand = InventoryImport::Gegenstand.find(:first, :conditions => ['original_id = ?', item.Inv_Serienr])
      #gegenstand = InventoryImport::Gegenstand.new unless gegenstand
      if gegenstand and not ["ITZ"].include?(item.Stao_Abteilung)
       # puts "Found: #{item.Inv_Serienr} - #{item.Art_Bezeichnung} = #{gegenstand.modellbezeichnung}"
        attributes = {
          :name => item.Art_Bezeichnung,
          :manufacturer => item.Art_Hersteller,
          :description => gegenstand.paket.nil? ? "" : gegenstand.paket.hinweise,
          :internal_description => gegenstand.paket.nil? ? "" : gegenstand.paket.hinweise_ausleih,
          :rental_price => gegenstand.paket.nil? ? 0 : gegenstand.paket.price,
          :info_url => gegenstand.info_url
        }
        model = Model.find_or_create_by_name attributes
        model.update_attributes(attributes)
        
        add_picture(model, gegenstand.bild_url) if gegenstand.bild_url and not gegenstand.bild_url.blank? and model.images.size == 0
        
        category = Category.find_or_create_by_name :name => item.Art_Gruppe_2
        category.models << model unless model.id == 0 || category.models.include?(model) # OPTIMIZE 13** avoid condition, check uniqueness on ModelLink
      
        item_attributes = {
          :inventory_code => (item.Inv_Abteilung + item.Inv_Serienr.to_s),
          :serial_number => item.Art_Serienr,
          :model => model,
          :location => get_location(item.Stao_Abteilung, item.Stao_Raum),
          :owner => get_owner(item.Inv_Abteilung),
          :last_check => gegenstand.letzte_pruefung,
          :required_level => (gegenstand.paket and gegenstand.paket.ausleihbefugnis > 1) ? AccessRight::EMPLOYEE : AccessRight::CUSTOMER,
          :retired => gegenstand.ausmusterdatum,
          :retired_reason => gegenstand.ausmustergrund,
          :invoice_number => item.Lief_Rechng_Nr,
          :invoice_date => item.Lief_Rechng_Dat,
          :is_incomplete => gegenstand.paket.nil? ? false : (gegenstand.paket.status == 0),
          :is_broken => gegenstand.paket.nil? ? false : (gegenstand.paket.status == -2),
          :is_borrowable => (item.rental == 'yes' and gegenstand.ausleihbar?),
          :price => (gegenstand.kaufvorgang.nil? or gegenstand.kaufvorgang.kaufpreis.nil?) ? 0 : gegenstand.kaufvorgang.kaufpreis / 100,
          :supplier => Supplier.find_or_create_by_name({ :name => item.Lief_Firma || item.Lief_Code })
        }
        
        if gegenstand.ausmusterdatum.blank?
          i = Item.find_or_create_by_inventory_code item_attributes
          i.update_attributes(item_attributes)
          
          #Add misc. stuff as notes.
          unless item.Art_Zusatz.blank? || item.Art_Zusatz == "-"
            #puts "Artikel Zusatz: #{i.id} - #{item.Art_Zusatz}"
            i.log_history(item.Art_Zusatz, nil)
          end
          
          unless item.Eingebaut_in.blank?
            #puts "Eingebaut: #{i.id} - #{item.Eingebaut_in}"
            i.log_history("Eingebaut in: #{item.Eingebaut_in}", nil)
          end
          
          #If the item now belongs to a different Model - Remap existing contract lines to the new model.
          i.contract_lines.each do | line |
            line.update_attributes(:model => model)
          end
          count += 1
          break if count == max
        else
          i = Item.find_by_inventory_code(item_attributes[:inventory_code])
          if i
            puts "Retiring (i.e. deleting) #{i.inventory_code}"
            i.destroy
          end
        end
      else
        add_message "Not Found in leihs: #{item.Inv_Serienr} - #{item.Art_Bezeichnung}" unless gegenstand
        add_message "#{item.Stao_Abteilung} Items are not being imported." if gegenstand
        
      end
      
    end
    messages
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
        add_message("Couldn't create file: #{url} for #{model.name}")
      end
    else
      add_message("Couldn't download: #{url} (for #{model.name})")
    end
  rescue
    add_message("Couldn't append #{url} to #{model.name}")
  end
  
  def add_message(text)
    puts text
    self.messages << text
  end
  
  # TODO import building, room and shelf
  def get_location(inventory_pool_name, location_room)
    return Location.find_or_create(:room => location_room)
  end
  
  def get_owner(dept)
    o = InventoryPool.find_by_name(dept[0..2])
    o = InventoryPool.find_by_name(dept[0..2]) unless o
    o
  rescue
    
  end
  
  
  def use_new_name_for(inv_abt)
  #  puts "Did the name change for: #{inv_abt}?"
    return "VMK" if inv_abt.upcase == "SNM" 
    return "VMK" if inv_abt.upcase == "VNM"
    return "VIAD" if inv_abt.upcase == "IAD"
    return "VTO" if inv_abt.upcase == "TMS"
    inv_abt
  end
  
  
  def import_inventory_pools
    parks = InventoryImport::Geraetepark.find(:all)
    parks.each do |park|
      inv_park = InventoryPool.find_or_create_by_name({
        :name => park.name,
        :logo_url => park.logo_url,
        :description => park.beschreibung,
        :contact_details => park.ansprechpartner,
        :contract_description => park.vertrag_bezeichnung,
        :contract_url => park.vertrag_url        
      })
    end
  end

####################################################################

  def connect_dev
    InventoryImport::Geraetepark.establish_connection(leihs_dev)
    InventoryImport::Gegenstand.establish_connection(leihs_dev)
    InventoryImport::Kaufvorgang.establish_connection(leihs_dev)
    InventoryImport::Paket.establish_connection(leihs_dev)
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

####################################################################
  
  def connect_prod
    InventoryImport::Geraetepark.establish_connection(leihs_prod)
    InventoryImport::Gegenstand.establish_connection(leihs_prod)
    InventoryImport::Kaufvorgang.establish_connection(leihs_prod)
    InventoryImport::Paket.establish_connection(leihs_prod)
    InventoryImport::ItHelp.establish_connection(it_help_prod)
  end

  def it_help_prod
    {   :adapter => 'mysql',
        :host => '195.176.254.49',
        :database => 'ithelp_alt',
        :encoding => 'utf8',
        :username => 'helpread',
        :password => '2read.0nly!' }
  end
  
  def leihs_prod
    {   :adapter => 'mysql',
        :host => '195.176.254.49',
        :database => 'rails_leihs',
        :encoding => 'utf8',
        :username => 'leihsread',
        :password => '2read.0nly!' }
  end


end
