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
    if is_package? and order_lines.empty? and contract_lines.empty?
      items.destroy_all
    end
  end

  has_many :items, dependent: :restrict # NOTE these are only the active items (unretired), because Item has a default_scope
  accepts_nested_attributes_for :items, :allow_destroy => true

  has_many :unretired_items, :class_name => "Item", :conditions => {:retired => nil} # TODO this is used by the filter
  #TODO  do we need a :all_items ??
  has_many :borrowable_items, :class_name => "Item", :conditions => {:retired => nil, :is_borrowable => true, :parent_id => nil}
  has_many :unborrowable_items, :class_name => "Item", :conditions => {:retired => nil, :is_borrowable => false}
  has_many :unpackaged_items, :class_name => "Item", :conditions => {:parent_id => nil}
  
  has_many :locations, :through => :items, :uniq => true  # OPTIMIZE N+1 select problem, :include => :inventory_pools
  has_many :inventory_pools, :through => :items, :uniq => true

  has_many :partitions, :dependent => :delete_all do
    def set_in(inventory_pool, new_partitions)
      where(:inventory_pool_id => inventory_pool).scoping do
        delete_all
        new_partitions.delete(Group::GENERAL_GROUP_ID)
        unless new_partitions.blank?
          valid_group_ids = inventory_pool.group_ids
          new_partitions.each_pair do |group_id, quantity|
            group_id = group_id.to_i
            quantity = quantity.to_i
            create(:group_id => group_id, :quantity => quantity) if valid_group_ids.include?(group_id) and quantity > 0
          end
        end
        # if there's no more items of a model in a group accessible to the customer, then he shouldn't be able to see the model in the frontend.
      end
    end
  end
  accepts_nested_attributes_for :partitions, :allow_destroy => true
  
  has_many :order_lines, dependent: :restrict
  has_many :contract_lines, dependent: :restrict
  has_many :properties, :dependent => :destroy
  accepts_nested_attributes_for :properties, :allow_destroy => true

  has_many :accessories, :dependent => :destroy
  accepts_nested_attributes_for :accessories, :allow_destroy => true

  has_many :images, :dependent => :destroy
  accepts_nested_attributes_for :images, :allow_destroy => true

  has_many :attachments, :dependent => :destroy
  accepts_nested_attributes_for :attachments, :allow_destroy => true

  # ModelGroups
  has_many :model_links, :dependent => :destroy
  has_many :model_groups, :through => :model_links, :uniq => true
  has_many :categories, :through => :model_links, :source => :model_group, :conditions => {:type => 'Category'}
  has_many :templates, :through => :model_links, :source => :model_group, :conditions => {:type => 'Template'}

########
  # says which other Model one Model works with
  has_and_belongs_to_many :compatibles,
                          :class_name => "Model",
                          :join_table => "models_compatibles",
                          :foreign_key => "model_id",
                          :association_foreign_key => "compatible_id",
                          :uniq => true

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

  SEARCHABLE_FIELDS = %w(name manufacturer)

  scope :search, lambda { |query , fields = []|
    return scoped if query.blank?

    sql = select("DISTINCT models.*") #old# joins(:categories, :properties, :items)
    if fields.empty?
      sql = sql.
        joins("LEFT JOIN `model_links` AS ml2 ON `ml2`.`model_id` = `models`.`id`").
        joins("LEFT JOIN `model_groups` AS mg2 ON `mg2`.`id` = `ml2`.`model_group_id` AND `mg2`.`type` = 'Category'").
        joins("LEFT JOIN `properties` AS p2 ON `p2`.`model_id` = `models`.`id`")
    end
    sql = sql.joins("LEFT JOIN `items` AS i2 ON `i2`.`model_id` = `models`.`id`") if fields.empty? or fields.include?(:items)

    # FIXME refactor to Arel
    query.split.each do |x|
      s = []
      s1 = ["' '"]
      s1 << "models.name" if fields.empty? or fields.include?(:name)
      s1 << "models.manufacturer" if fields.empty?
      s << "CONCAT_WS(#{s1.join(', ')}) LIKE :query"
      if fields.empty?
        s << "mg2.name LIKE :query"
        s << "p2.value LIKE :query"
      end
      s << "CONCAT_WS(' ', i2.inventory_code, i2.serial_number, i2.invoice_number, i2.note, i2.name, i2.user_name, i2.properties) LIKE :query" if fields.empty? or fields.include?(:items)
      
      sql = sql.where("%s" % s.join(' OR '), :query => "%#{x}%")
    end
    sql
  }
  
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

  # returns an array of document_lines
  def add_to_document(document, user_id, quantity = nil, start_date = nil, end_date = nil, inventory_pool = nil)
    document.add_lines(quantity, self, user_id, start_date, end_date, inventory_pool)
  end  
                                                                                                      
end

