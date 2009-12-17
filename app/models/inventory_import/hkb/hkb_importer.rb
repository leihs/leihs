require 'net/http'
require 'uri'
require 'faster_csv'

class HkbImporter
  
  INV_NR = 0
  BFH_NR = 1
  CATEGORY = 2
  SET = 3
  HERSTELLER = 4
  BEZEICHNUNG = 5
  SERIAL_NR = 6
  PREIS = 7
  ROOM = 8
  KAUFDATUM = 9
  KOMMENTAR = 10
  BILDLINK = 11
  INFOLINK = 12
  ABMESSUNG = 13
  INV_ABT = 14
  HERAUSGABE_ABT = 15
  BORROWABLE_ALLOWED = 16
  BORROWABLE = 17 
  BUILDING = 18

  
  attr_accessor :messages
  
  def start(filename, ip_name)
    self.messages = []
    
    def_ip = create_inventory_pool("HKB MediaLab")
    parent_category = Category.find_or_create_by_name(:name => ip_name)    
    
    line_count = 1
    
    #File.open(filename) do |file|
      FasterCSV.read(filename, :col_sep => ";", :headers => :first_row ).each do |line|
        line_count = line_count + 1
        if line_count > 1
          field = line
         
          ip = Item.find(:first, :conditions => ['inventory_code like ?', "%-#{field[0]}"])
          ip = ip ? ip.inventory_pool : def_ip

          if field[SET] != nil and not field[SET].strip.empty?
            attributes = {
              :name => field[SET],
              :manufacturer => "",
              :is_package => true
            }
            package = Model.find_or_create_by_name attributes
            package.update_attributes(attributes)
    
            add_to_category(parent_category, field[CATEGORY], package)
            
            puts "#{package.id} #{package.name}"
                   
            if package.items.empty?
              item_attributes = {
                :inventory_code => "P#{ip.id}-#{field[0]}",
                :model => package,
                :location => get_location(ip.name, "---"),
                :owner => ip,
                :inventory_pool => ip,
                :required_level => AccessRight::CUSTOMER,
                :is_incomplete => false,
                :is_broken => false,
                :is_borrowable => "ja".eql?(field[BORROWABLE].downcase.strip)
              }
              package_item = Item.find_or_create_by_inventory_code item_attributes
              package_item.update_attributes(item_attributes)
            else
              package_item = package.items.first
              package_item.update_attribute(:is_borrowable, "ja".eql?(field[BORROWABLE].downcase.strip))
            end
          end
  
          if not field[BEZEICHNUNG].blank?
            #puts "#{field[PREIS]}"
            attributes = {
              :name => field[BEZEICHNUNG],
              :manufacturer => field[HERSTELLER],
              :info_url => field[INFOLINK]
            }
            model = Model.find_or_create_by_name attributes
            model.update_attributes(attributes)          
            puts "#{line_count} - #{model.errors.length}" if model.errors.length > 0
            
            add_picture(model, field[BILDLINK]) if field[BILDLINK] and not field[BILDLINK].blank? and model.images.size == 0
  
            add_to_category(parent_category, field[CATEGORY], model)
            
            item_attributes = {
              :inventory_code => "#{ip.id}-#{field[INV_NR]}",
              :serial_number => field[SERIAL_NR],
              :model => model,
              :location => get_location(field[BUILDING], field[ROOM]),
              :owner => ip,
              :inventory_pool => ip,
              :required_level => AccessRight::CUSTOMER,
              :is_incomplete => false,
              :is_broken => false,
              :parent_id => (package_item.nil? ? nil : package_item.id),
              :is_borrowable => "ja".eql?(field[BORROWABLE].downcase.strip),
              :price => field[PREIS].to_f * 100
            }
            i = Item.find_or_create_by_inventory_code item_attributes
            i.update_attributes(item_attributes)
          end
        end
      end
    #end
    puts "#{line_count} lines"
    return
    
  end
  
  def add_to_category(parent_category, cat_name, model)
    
    category = Category.find_or_create_by_name(:name => cat_name)
    unless category.parents.include?(parent_category)
      category.parents << parent_category 
      category.save
      
      puts "#{category.id} *#{parent_category.name} - #{category.name}*"
    end
    
    unless category.models.include?(model) # OPTIMIZE 13** avoid condition, check uniqueness on ModelLink
      category.models << model
      category.save
    end
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
  def get_location(building_name, room)
    building = Building.find_or_create_by_name(building_name)
    return Location.find_or_create(:building_id => building, :room => room)
  end
  
  def get_owner(dept)
    o = InventoryPool.find_by_name(dept[0..2])
    o = InventoryPool.find_by_name(dept[0..2]) unless o
    o
  rescue
    
  end
  
  
  def create_inventory_pool(name)
    InventoryPool.find_or_create_by_name({
      :name => "#{name}",
      :description => "",
      :contact_details => "",
      :contract_description => "",
      :contract_url => ""        
    })
  end


end


i = HkbImporter.new
i.start ARGV[0], ARGV[1]