class Model < ActiveRecord::Base

  def before_destroy
    errors.add_to_base "Model cannot be destroyed because related items are still present." if items.count(:retired => :all) > 0
    if is_package? and order_lines.empty? and contract_lines.empty?
      items.destroy_all
    else
      return false
    end
  end

  has_many :items
  has_many :unretired_items, :class_name => "Item", :conditions => {:retired => nil}
  has_many :borrowable_items, :class_name => "Item", :conditions => {:retired => nil, :is_borrowable => true, :parent_id => nil}
  
  has_many :locations, :through => :items, :uniq => true  # OPTIMIZE N+1 select problem, :include => :inventory_pools
  has_many :inventory_pools, :through => :items, :uniq => true
  
  has_many :order_lines
  has_many :contract_lines
  has_many :properties, :dependent => :destroy
  has_many :accessories, :dependent => :destroy
  has_many :images, :dependent => :destroy

  # ModelGroups
  has_many :model_links, :dependent => :destroy
  has_many :model_groups, :through => :model_links, :uniq => true
  has_many :categories, :through => :model_links, :source => :model_group, :conditions => {:type => 'Category'}
  has_many :templates, :through => :model_links, :source => :model_group, :conditions => {:type => 'Template'}
  
  # Packages
  has_many :package_items, :through => :items, :source => :children
  def package_models
    # NOTE assuming all roots have the same children structure
    items.each do |item|
      return item.children.collect(&:model) unless item.children.empty?
    end if is_package?
    return []
  end
                
########
  has_and_belongs_to_many :compatibles,
                          :class_name => "Model",
                          :join_table => "models_compatibles",
                          :foreign_key => "model_id",
                          :association_foreign_key => "compatible_id",
                     #TODO :insert_sql => "INSERT INTO models_compatibles (model_id, compatible_id)
                     #                 VALUES (#{id}, #{record.id}), (#{record.id}, #{id})" 
                          :after_add => :add_bidirectional_compatibility,
                          :after_remove => :remove_bidirectional_compatibility
  def add_bidirectional_compatibility(compatible)
    compatible.compatibles << self unless compatible.compatibles.include?(self)
  end
  
  def remove_bidirectional_compatibility(compatible)
    compatible.compatibles.delete(self) if compatible.compatibles.include?(self)
  end

#############################################  

  validates_presence_of :name
  validates_uniqueness_of :name

#############################################  

  # OPTIMIZE Mysql::Error: Not unique table/alias: 'items'
  named_scope :active, :select => "DISTINCT models.*",
                       :joins => :items,
                       :conditions => "items.retired IS NULL"

  named_scope :without_items, :select => "models.*",
                              :joins => "LEFT JOIN items ON items.model_id = models.id",
                              :conditions => ['items.model_id IS NULL']
                              
  named_scope :packages, :conditions => { :is_package => true }
  
  named_scope :with_properties, :select => "DISTINCT models.*",
                                :joins => "LEFT JOIN properties ON properties.model_id = models.id",
                                :conditions => "properties.model_id IS NOT NULL"

  named_scope :by_inventory_pool, lambda { |inventory_pool| { :select => "DISTINCT models.*",
                                                              :joins => :items,
                                                              :conditions => ["items.inventory_pool_id = ?", inventory_pool] } }

  named_scope :by_categories, lambda { |categories| { :select => "DISTINCT models.*",
                                                      :joins => "INNER JOIN model_links AS ml", # OPTIMIZE no ON ??
                                                      :conditions => ["ml.model_group_id IN (?)", categories] } }

#############################################  

  define_index do
    indexes :name, :sortable => true
    indexes :manufacturer, :sortable => true
    indexes categories(:name), :as => :category_names
    indexes properties(:value), :as => :properties_values
    indexes items(:inventory_code), :as => :items_inventory_codes
    
    has :is_package
    has compatibles(:id), :as => :compatible_id
    has categories(:id), :as => :category_id
#    has items(:inventory_pool_id), :as => :inventory_pool_id
#    has items(:owner_id), :as => :owner_id
    has unretired_items(:inventory_pool_id), :as => :unretired_inventory_pool_id
    has unretired_items(:owner_id), :as => :unretired_owner_id
#    has borrowable_items(:inventory_pool_id), :as => :borrowable_inventory_pool_id
    
    # set_property :order => :name
    set_property :delta => true
  end

  define_index "frontend_model" do
    # where "is_package = 1"
    
    indexes :name, :sortable => true
    indexes :manufacturer, :sortable => true
    
    has :is_package
    has categories(:id), :as => :category_id
    has borrowable_items(:inventory_pool_id), :as => :borrowable_inventory_pool_id
    
    set_property :delta => true
  end

#old#  sphinx_scope(:sphinx_active) { {:without => {:active_item_id => 0}} }
  sphinx_scope(:sphinx_packages) { {:with => {:is_package => true}} }

#############################################  

  def to_s
    "#{name}"
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.name <=> other.name
  end

  # TODO 06** define main image
  def image_thumb
    ( images.empty? ? nil : images.first.public_filename(:thumb) )
  end

  def lines
    order_lines.submitted + contract_lines
  end
  
  def needs_permission
    items.each do |item|
      return true if item.needs_permission
    end
    return false
  end
#############################################  
# Availability
#############################################  
# OPTIMIZE Cache
#  [:inventory_pool_id][:model_id][:level ??][:periods]
#  { 1 => { 1 => [["2010-01-20", "2010-01-22", 3], ["2010-01-23", "2010-01-27", 6]] } }

# OPTIMIZE this method is only used as helper for the un... method ?? 
  def available_periods_for_document_line(document_line, current_time = Date.today)
    create_availability(current_time, document_line, document_line.inventory_pool, document_line.document.user).periods
  end

  def unavailable_periods_for_document_line(document_line, current_time = Date.today)
    u = available_periods_for_document_line(document_line, current_time).select { |a| a.quantity < document_line.quantity }

    # NOTE even if start_date or end_date are nil,
    # make sure they are set in order to have (it may occur when an item is unborrowable)
    # TODO refactor to Availability#periods ??
    u.each do |a|
      a.start_date = current_time unless a.start_date
      a.end_date = a.start_date + 1.year unless a.end_date
    end

    u
  end
  
  # TODO *e* inventory_pools array ??
  def available_periods_for_inventory_pool(inventory_pool, user, current_time = Date.today)
    create_availability(current_time, nil, inventory_pool, user).periods
  end

# OPTIMIZE this method is not used anymore ??
#  def available_dates_for_document_line(start_date, end_date, document_line, current_time = Date.today)
#    create_availability(current_time, document_line, document_line.inventory_pool, document_line.document.user).dates(start_date, end_date)
#  end

# OPTIMIZE this method is not used anymore ??
#  def available_dates_for_inventory_pool(start_date, end_date, inventory_pool, user, current_time = Date.today)
#    create_availability(current_time, nil, inventory_pool, user).dates(start_date, end_date)
#  end  

# OPTIMIZE this method is only used for test ??  
  # TODO *e* maximum_available_for_document_line method ??
  def maximum_available_for_inventory_pool(date, inventory_pool, user, current_time = Date.today)
    create_availability(current_time, nil, inventory_pool, user).period_for(date).quantity
  end
  
  def maximum_available_in_period_for_document_line(start_date, end_date, document_line, current_time = Date.today)
    if (start_date.nil? && end_date.nil?)
      return items.size
    else
      create_availability(current_time, document_line, document_line.inventory_pool, document_line.document.user).maximum_available_in_period(start_date, end_date)
    end
  end  

  def maximum_available_in_period_for_inventory_pool(start_date, end_date, inventory_pool, user, current_time = Date.today)
    if (start_date.nil? && end_date.nil?)
      return items.size
    else
      create_availability(current_time, nil, inventory_pool, user).maximum_available_in_period(start_date, end_date)
    end
  end  


#############################################  

  def add_to_document(document, user_id, quantity = nil, start_date = nil, end_date = nil, inventory_pool = nil)
    document.add_line(quantity, self, user_id, start_date, end_date, inventory_pool)
  end  

  private
  
  def create_availability(current_time, document_line, inventory_pool, user)
    i = self.items.borrowable.all(:conditions => ['required_level <= ? AND inventory_pool_id = ?',
                                                  (user.nil? ? 1 : user.level_for(inventory_pool)), inventory_pool.id])    
                             
    r = DocumentLine.current_and_future_reservations(id, inventory_pool, document_line, current_time)
    
    a = Availability.new(i.size, Date.today, nil, current_time)
    a.model = self
    a.reservations(r)
    a
  end
  
end
