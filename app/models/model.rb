class Model < ActiveRecord::Base
  has_many :items # TODO filter children items, has_many :all_items ??
  has_many :locations, :through => :items, :uniq => true
  has_many :inventory_pools, :through => :locations, :uniq => true
  
  has_many :order_lines
  has_many :contract_lines
  has_many :properties
  has_many :accessories
  has_many :images

  # ModelGroups
  has_many :model_links
  has_many :model_groups, :through => :model_links, :uniq => true
  has_many :categories, :through => :model_links, :source => :model_group, :conditions => {:type => 'Category'}
  has_many :templates, :through => :model_links, :source => :model_group, :conditions => {:type => 'Template'}
                
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
    compatible.compatibles.delete(self) rescue nil
  end
########

  named_scope :without_items, :select => "models.*",
                              :joins => "LEFT JOIN items ON items.model_id = models.id",
                              :conditions => ['items.model_id IS NULL']

  # TODO test it
  named_scope :packages, :select => "DISTINCT models.*",
                         :joins => "LEFT JOIN items j ON models.id = j.model_id JOIN items i ON j.id = i.parent_id",
                         :conditions => ['j.parent_id IS NULL']
  
#############################################  

  validates_uniqueness_of :name
  #validates_length_of :name, :minimum => 1 #, :too_short => "please enter at least %d character", :if => Proc.new {|i| i.step == :step_item}
  validates_presence_of :name #, :if => Proc.new {|i| i.step == :step_item}

  acts_as_ferret :fields => [ :name, :category_names, :properties_values ], :store_class_name => true

#############################################  

  # compares two objects in order to sort them
  def <=>(other)
    self.name <=> other.name
  end
  
  def is_package?
    items.size == 1 and items.first.is_package?
  end

#############################################  
# Availability
#############################################  

  def available_periods_for_document_line(document_line, current_time = Date.today)
    create_availability(current_time, document_line, document_line.inventory_pool).periods
  end

  # TODO *e* inventory_pools array ??
  def available_periods_for_inventory_pool(inventory_pool, current_time = Date.today)
    create_availability(current_time, nil, inventory_pool).periods
  end

  # TODO *e* available_dates_for_inventory_pool method ??
  def available_dates_for_document_line(start_date, end_date, document_line, current_time = Date.today)
    create_availability(current_time, document_line, document_line.inventory_pool).dates(start_date, end_date)
  end
  
  # TODO *e* maximum_available_for_document_line method ??
  def maximum_available_for_inventory_pool(date, inventory_pool, current_time = Date.today)
    create_availability(current_time, nil, inventory_pool).period_for(date).quantity
  end
  
  def maximum_available_in_period_for_document_line(start_date, end_date, document_line, current_time = Date.today)
    if (start_date.nil? && end_date.nil?)
      return items.size
    else
      create_availability(current_time, document_line, document_line.inventory_pool).maximum_available_in_period(start_date, end_date)
    end
  end  

  def maximum_available_in_period_for_inventory_pool(start_date, end_date, inventory_pool, current_time = Date.today)
    if (start_date.nil? && end_date.nil?)
      return items.size
    else
      create_availability(current_time, nil, inventory_pool).maximum_available_in_period(start_date, end_date)
    end
  end  
#############################################  


  def add_to_document(document, user_id, quantity = nil, start_date = nil, end_date = nil, inventory_pool = nil)
    document.add_line(quantity, self, user_id, start_date, end_date, inventory_pool)
  end  

  private
  
  def create_availability(current_time, document_line, inventory_pool)    
    i = self.items.find(:all,
                        :joins => :location,
                        :conditions => ['status_const = ? AND locations.inventory_pool_id = ?',
                                        Item::BORROWABLE, inventory_pool.id])
    r = DocumentLine.current_and_future_reservations(id, inventory_pool, document_line, current_time)
    
    a = Availability.new(i.size, Date.today, nil, current_time)
    a.model = self
    a.reservations(r)
    a
  end
  
  def category_names
    categories.collect(&:name).uniq.join(" ")
  end

  def properties_values
    properties.collect(&:value).uniq.join(" ")
  end
  
end
