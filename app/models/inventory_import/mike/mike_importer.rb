
class MikeImporter
  
  attr_accessor :messages
  
    OWNER = 0
    INV_NR = 1
    MODEL_NAME = 2
    CATEGORY = 3
    BUILDING = 4
    ROOM = 5
    DEPARTEMENT = 6
    SERIAL_NR = 7
    INVOICE_DATE = 8
    VALUE = 9
    SUPPLIER = 10
    PERFORMANCE = 11
    FASSUNG = 12
    WEIGHT = 13
    LAMP_TYPE = 14
    APPARATE_NR = 15
    
  def start(filename, ip_name)
    
    self.messages = []
    puts "Starting Mikes Import"
    
    btk = create_inventory_pool("BTK")
    flo = create_inventory_pool("FHG")
    avz = create_inventory_pool("AVZ")
    
    #parent_category = Category.find_or_create_by_name(:name => ip_name)
    
    line_count = 0
    File.open(filename) do |file|
      file.each_line do |line|
        line_count = line_count + 1
        if line_count > 1
          field = line.split(";")
          ip = btk if field[OWNER].eql?("AV-Technik")
          ip = flo if field[OWNER].eql?("Bühnentechnik PZ")
          
          attributes = {
            :name => field[MODEL_NAME]
          }
          model = Model.find_or_create_by_name attributes
          model.update_attributes(attributes)

          #Add Properties
          if (not field[PERFORMANCE].blank? and model.properties.detect {|d| d.key.eql? 'Leistung'}.nil?)
            puts model.properties.inspect
            model.properties.create(:key => 'Leistung', :value => field[PERFORMANCE])
          end 
          model.properties.create(:key => 'Fassung', :value => field[FASSUNG]) if (not field[FASSUNG].blank? and model.properties.detect {|d| d.key.eql? 'Fassung'}.nil?)
          model.properties.create(:key => 'Gewicht', :value => field[WEIGHT]) if (not field[WEIGHT].blank? and model.properties.detect {|d| d.key.eql? 'Gewicht'}.nil?)
          model.properties.create(:key => 'Lampentyp', :value => field[LAMP_TYPE]) if (not field[LAMP_TYPE].blank? and model.properties.detect {|d| d.key.eql? 'Lampentyp'}.nil?)
          model.properties.create(:key => 'Apparate-Nr', :value => field[APPARATE_NR]) if (not field[APPARATE_NR].blank? and model.properties.detect {|d| d.key.eql? 'Apparate-Nr'}.nil?)
          
          model.save

          puts "Line #{line_count} - Model #{field[MODEL_NAME]} created with #{model.errors.length} errors"
          if model.errors.length > 0
            puts model.errors.inspect
          end
          category = Category.find_or_create_by_name(:name => field[CATEGORY])
                      
          unless category.models.include?(model)
            category.models << model
            category.save
          end
        
          item_attributes = {
            :inventory_code => field[INV_NR],
            :serial_number => field[SERIAL_NR],
            :model => model,
            :location => get_location(field[BUILDING], field[ROOM]),
            :owner => avz,
            :required_level => AccessRight::CUSTOMER,
            :is_incomplete => false,
            :is_broken => false,
            :is_borrowable => true,
            :is_inventory_relevant => true,
            :inventory_pool => ip,
            :price => field[VALUE],
            :supplier => Supplier.find_or_create_by_name(:name => field[SUPPLIER]),
            :responsible => field[DEPARTEMENT],
            :invoice_date => field[INVOICE_DATE]
          }
          i = Item.find_or_create_by_inventory_code item_attributes
          i.update_attributes(item_attributes)
          if i.errors.length > 0 
            puts i.errors.inspect
          end
        end
      end
    end
    puts "#{line_count} lines"
    return
    
  end
  
  def add_message(text)
    puts text
    self.messages << text
  end
  
  # TODO import building, room and shelf
  def get_location(building, room)
    b = Building.find_or_create_by_name(:name => building)
    location = Location.find(:first, :conditions => {:room => room, :building_id => b.id})
    location = Location.create(:room => room, :building_id => b.id) unless location
    return location
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


i = MikeImporter.new
i.start ARGV[0], ARGV[1]