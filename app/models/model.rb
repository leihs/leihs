# A Model is a type of a thing which is available inside
# an #InventoryPool for borrowing. If a customer wants to
# borrow a thing, he opens an #Order and chooses the
# appropriate Model. The #InventoryPool manager then hands
# him over an instance - an #Item - of that Model, in case
# one is still available for borrowing.
#
# The description of the #Item class contains an example.
#
#
class Model < ActiveRecord::Base
  include Availability::Model
  acts_as_audited
  has_associated_audits

  before_destroy do
    errors.add(:base, "Model cannot be destroyed because related items are still present.") if Item.unscoped { items.count } > 0
    if is_package? and order_lines.empty? and contract_lines.empty?
      items.destroy_all
    else
      return false
    end

# TODO allow to delete a model that doesn't have items
#    if is_package? and order_lines.empty? and contract_lines.empty?
#      items.destroy_all
#    elsif Item.unscoped { items.count } > 0
#      errors.add(:base, "Model cannot be destroyed because related items are still present.")
#      return false
#    end
  end

  has_many :items # NOTE these are only the active items (unretired), because Item has a default_scope
  has_many :unretired_items, :class_name => "Item", :conditions => {:retired => nil} # TODO this is used by the filter
  #TODO  do we need a :all_items ??
  has_many :borrowable_items, :class_name => "Item", :conditions => {:retired => nil, :is_borrowable => true, :parent_id => nil}
  has_many :unborrowable_items, :class_name => "Item", :conditions => {:retired => nil, :is_borrowable => false}
  has_many :unpackaged_items, :class_name => "Item", :conditions => {:parent_id => nil}
  
  has_many :locations, :through => :items, :uniq => true  # OPTIMIZE N+1 select problem, :include => :inventory_pools
  has_many :inventory_pools, :through => :items, :uniq => true

  has_many :partitions, :dependent => :delete_all do
    def in(inventory_pool)
      # At this point partitions are model scoped, additionally
      # we want to scope them for inventory pool too (double scope).
      Partition::Scoped.new(inventory_pool, proxy_association.owner,
                           self.scoped.where(:inventory_pool_id => inventory_pool))
    end
  end
  
  has_many :order_lines
  has_many :contract_lines
  has_many :properties, :dependent => :destroy
  has_many :accessories, :dependent => :destroy
  has_many :images, :dependent => :destroy
  has_many :attachments, :dependent => :destroy

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
  # says which other Model one Model works with
  has_and_belongs_to_many :compatibles,
                          :class_name => "Model",
                          :join_table => "models_compatibles",
                          :foreign_key => "model_id",
                          :association_foreign_key => "compatible_id",
                     #TODO :insert_sql => "INSERT INTO models_compatibles (model_id, compatible_id)
                     #                 VALUES (#{id}, #{record.id}), (#{record.id}, #{id})" 
                          :after_add => [:add_bidirectional_compatibility],
                          :after_remove => [:remove_bidirectional_compatibility]
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
  scope :active, select("DISTINCT models.*").joins(:items).where("items.retired IS NULL")

  scope :without_items, select("models.*").joins("LEFT JOIN items ON items.model_id = models.id").
                        where(['items.model_id IS NULL'])
                              
  scope :packages, where(:is_package => true)
  
  scope :with_properties, select("DISTINCT models.*").
                          joins("LEFT JOIN properties ON properties.model_id = models.id").
                          where("properties.model_id IS NOT NULL")

  scope :by_inventory_pool, lambda { |inventory_pool| select("DISTINCT models.*").joins(:items).
                                                      where(["items.inventory_pool_id = ?", inventory_pool]) }

  scope :by_categories, lambda { |categories| joins("INNER JOIN model_links AS ml"). # OPTIMIZE no ON ??
                                              where(["ml.model_group_id IN (?)", categories]) }

#############################################

  def self.search2(query, fields = [])
    return scoped unless query

    sql = select("DISTINCT models.*") #old# joins(:categories, :properties, :items)
    if fields.empty?
      sql = sql.
        joins("LEFT JOIN `model_links` AS ml2 ON `ml2`.`model_id` = `models`.`id`").
        joins("LEFT JOIN `model_groups` AS mg2 ON `mg2`.`id` = `ml2`.`model_group_id` AND `mg2`.`type` = 'Category'").
        joins("LEFT JOIN `properties` AS p2 ON `p2`.`model_id` = `models`.`id`")
    end
    sql = sql.joins("LEFT JOIN `items` AS i2 ON `i2`.`model_id` = `models`.`id`") if fields.empty? or fields.include?(:items)

    w = query.split.map do |x|
      s = []
      s1 = ["' '"]
      s1 << "models.name" if fields.empty? or fields.include?(:name)
      s1 << "models.manufacturer" if fields.empty?
      s << "CONCAT_WS(#{s1.join(', ')}) LIKE '%#{x}%'"
      if fields.empty?
        s << "mg2.name LIKE '%#{x}%'"
        s << "p2.value LIKE '%#{x}%'"
      end
      s << "CONCAT_WS(' ', i2.inventory_code, i2.serial_number, i2.invoice_number, i2.note, i2.name) LIKE '%#{x}%'" if fields.empty? or fields.include?(:items)

      "(%s)" % s.join(' OR ')
    end.join(' AND ')
    sql.where(w)
  end
  
  def self.filter2(options)
    sql = select("DISTINCT models.*")
    options.each_pair do |k,v|
      case k
        when :inventory_pool_id
          # NOTE joins(:items) doesn't consider the Item#default_scope
          sql = sql.joins(:unretired_items).where(:items => {k => v})
      end
    end
    sql
  end

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
    images.first.try(:public_filename, :thumb)
  end
  
  def image
    images.first.try(:public_filename)
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

  def add_to_document(document, user_id, quantity = nil, start_date = nil, end_date = nil, inventory_pool = nil)
    document.add_line(quantity, self, user_id, start_date, end_date, inventory_pool)
  end  

  def running_reservations(inventory_pool, current_time = Date.today)
    return   self.contract_lines.by_inventory_pool(inventory_pool).handed_over_or_assigned_but_not_returned(current_time) \
           + self.order_lines.scoped_by_inventory_pool_id(inventory_pool).submitted.running(current_time)    
  end
                                                                                                      
end

