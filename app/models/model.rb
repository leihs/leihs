class Model < ActiveRecord::Base
  has_many :items
  has_many :locations, :through => :items, :uniq => true
  has_many :inventory_pools, :through => :locations, :uniq => true
  
  has_many :order_lines
  has_many :contract_lines
  has_many :properties
  has_many :accessories
  has_many :images

  # ModelGroups
  has_many :model_links
  has_many :model_groups, :through => :model_links #, :uniq => true
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

  validates_presence_of :name

  acts_as_ferret :fields => [ :name, :category_names, :properties_values ], :store_class_name => true

#############################################  

  # compares two objects in order to sort them
  def <=>(other)
    self.name <=> other.name
  end
  
#############################################  

  def availability(document_line = nil, current_time = Date.today)
    create_availability(current_time, document_line).periods
  end
  
  def availabilities(start_date, end_date, document_line = nil, current_time = Date.today)
    a = create_availability(current_time, document_line)
    ret = []
    start_date.upto(end_date) do |d|
      period = a.period_for(d)
      if period.nil?
        ret << [d, 0]
      else
        ret << [d, period.quantity]
      end
    end
    ret
  end
  
  def maximum_available(date, document_line = nil, current_time = Date.today)
    create_availability(current_time, document_line).period_for(date).quantity
  end
  
  def maximum_available_in_period(start_date, end_date, document_line = nil, current_time = Date.today)
    if (start_date.nil? && end_date.nil?)
      return items.size
    else
      create_availability(current_time, document_line).maximum_available_in_period(start_date, end_date)
    end
  end  
#############################################  


  def add_to_document(document, user_id, quantity = nil, start_date = nil, end_date = nil)
    quantity ||= 1
    document.add_line(quantity, self, user_id, start_date, end_date)
  end  
  
  
  
  private 
  
  def create_availability(current_time, document_line = nil)    
    i = self.items.find(:all, :conditions => {:status_const => Item::BORROWABLE})
    a = Availability.new(i.size)
    a.model = self
    a.reservations(DocumentLine.current_and_future_reservations(id, document_line, current_time))
    a
  end
  
  # TODO through model_links and model_groups
  def category_names
#    n = [] 
#    categories.each do |c|
#      n << c.name  
#    end
#    n.uniq.join(" ")
    ""
  end

  def properties_values
    n = [] 
    properties.each do |p|
      n << p.value  
    end
    n.uniq.join(" ")
  end
  
end
