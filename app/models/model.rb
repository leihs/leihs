class Model < ActiveRecord::Base
  has_many :items
  has_many :inventory_pools, :through => :items, :group => :id #, :uniq => true
  
  has_many :order_lines
  has_many :properties
  has_many :accessories

  has_and_belongs_to_many :categories

###
  has_and_belongs_to_many :packages,
                          :class_name => "Model",
                          :join_table => "models_packages",
                          :foreign_key => "model_id",
                          :association_foreign_key => "package_id"

  has_and_belongs_to_many :models,
                          :class_name => "Model",
                          :join_table => "models_packages",
                          :foreign_key => "package_id",
                          :association_foreign_key => "model_id"    
###
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
###

  named_scope :packages, :joins => "LEFT JOIN models_packages ON models_packages.package_id = models.id",
                         :conditions => ['models_packages.package_id IS NOT NULL']

    
  acts_as_ferret :fields => [ :name ] #, :store_class_name => true
                 # TODO indexing properties


  # TODO a package shouldn't have items ?
  def is_package?
    !models.empty? # and items.empty?
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


  
  
  
  private 
  
  def create_availability(current_time, document_line = nil)    
    i = self.items.find(:all, :conditions => ['status = ?', Item::AVAILABLE])
    a = Availability.new(i.size)
    a.model = self
    a.reservations(DocumentLine.current_and_future_reservations(id, document_line, current_time))
    a
  end
end
