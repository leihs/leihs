# == Schema Information
#
# Table name: models
#
#  id                   :integer(4)      not null, primary key
#  name                 :string(255)     not null
#  manufacturer         :string(255)
#  description          :string(255)
#  internal_description :string(255)
#  info_url             :string(255)
#  rental_price         :decimal(8, 2)
#  maintenance_period   :integer(4)      default(0)
#  is_package           :boolean(1)      default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#  technical_detail     :string(255)
#  delta                :boolean(1)      default(TRUE)
#

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
  has_many :unretired_items, :class_name => "Item", :conditions => {:retired => nil} # TODO this is redudant, do we need :retired_items ??
  #TODO  do we need a :all_items ??
  has_many :borrowable_items, :class_name => "Item", :conditions => {:retired => nil, :is_borrowable => true, :parent_id => nil}
  has_many :unpackaged_items, :class_name => "Item", :conditions => {:parent_id => nil}
  
  has_many :locations, :through => :items, :uniq => true  # OPTIMIZE N+1 select problem, :include => :inventory_pools
  has_many :inventory_pools, :through => :items, :uniq => true

  has_many :partitions, :dependent => :delete_all do
    def in(inventory_pool)
      # At this point partitions are model scoped, additionally
      # we want to scope them for inventory pool too (double scope).
      ScopedPartitions.new(inventory_pool, proxy_owner,
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
                          :after_add => [:add_bidirectional_compatibility, :update_sphinx_index_compatibility],
                          :after_remove => [:remove_bidirectional_compatibility, :update_sphinx_index_compatibility]
  def add_bidirectional_compatibility(compatible)
    compatible.compatibles << self unless compatible.compatibles.include?(self)
  end
  
  def remove_bidirectional_compatibility(compatible)
    compatible.compatibles.delete(self) if compatible.compatibles.include?(self)
  end
  
  def update_sphinx_index_compatibility(compatible)
    self.touch_for_sphinx
    compatible.touch_for_sphinx
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

  after_save :update_sphinx_index


#############################################

  def as_json(options = {})
    options ||= {} # NOTE workaround, because options is nil, is this a BUG ??

    current_user = options[:current_user]
    current_inventory_pool = options[:current_inventory_pool]
    
    required_options = {:include => [:properties, :categories] }
    
    # :methods => :inventory_pool_ids
    json = super(options.deep_merge(required_options))

    if current_user
      json['total_borrowable'] = total_borrowable_items_for_user(current_user)
      json['availability'] = availability_periods_for_user(current_user)
    end

    if current_inventory_pool
      active_items = items.scoped_by_inventory_pool_id(current_inventory_pool)
      json['total_borrowable'] = active_items.count
      json['availability'] = active_items.borrowable.in_stock.count
    end
    
    json.merge({:type => self.class.to_s.underscore})
  end


#############################################

  define_index do
    indexes :name, :sortable => true
    indexes :manufacturer, :sortable => true
    indexes categories(:name), :as => :category_names
    indexes properties(:value), :as => :properties_values
    indexes items(:inventory_code), :as => :items_inventory_codes
    
    has :is_package
    has compatibles(:id), :as => :compatible_id
    has model_groups(:id), :as => :model_group_id
#    has items(:inventory_pool_id), :as => :inventory_pool_id
#    has items(:owner_id), :as => :owner_id
    has unretired_items(:inventory_pool_id), :as => :inventory_pool_id
    has unretired_items(:owner_id), :as => :owner_id

    # item has at least one NULL parent_id and thus it has items that were not packaged
    # we collect all the inventory pools for which this is the case
    has "(SELECT GROUP_CONCAT(DISTINCT i.inventory_pool_id) FROM items i WHERE i.model_id = models.id AND i.parent_id IS NULL)",
        :as => :inventory_pools_with_unpackaged_items, :type => :multi
#    has unpackaged_items(:inventory_pool_id), :as => :unpackaged_inventory_pool_id
    
    # set_property :order => :name
    set_property :delta => true
  end

#old#  sphinx_scope(:sphinx_active) { {:without => {:active_item_id => 0}} }
  sphinx_scope(:sphinx_packages) { {:with => {:is_package => true}} }
  sphinx_scope(:sphinx_with_unpackaged_items) { |inventory_pool_id|
                                                {:with => {:inventory_pools_with_unpackaged_items => inventory_pool_id.to_s}} }

  def touch_for_sphinx
    @block_delta_indexing = true
    save # trigger reindex
  end

  private
  def update_sphinx_index
    return if @block_delta_indexing
    Item.suspended_delta do # FIXME doesn't work!!!
      items.each {|x| x.touch_for_sphinx }
    end
  end
  public

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

