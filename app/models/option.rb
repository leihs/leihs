# Options are things that can be borrowed. The are listed
# within #OptionLines which can be added to a #Contract.
# Options don't have their own barcode and thus don't have
# individual identities (contrary to #Item s) and thus can
# be given out by the #InventoryPool manager in arbitrary
# quantities. Also Options are not an instance of some
# #Model as id the case for #Item s.
#
class Option < ActiveRecord::Base
  acts_as_audited :associated_with => :inventory_pool
  has_associated_audits

  belongs_to :inventory_pool
  has_many :option_lines

  validates_presence_of :inventory_pool, :name
  validates_uniqueness_of :inventory_code, :scope => :inventory_pool_id, :unless => Proc.new { |record| record.inventory_code.blank? }

  before_validation do |record|
    record.inventory_code = nil if !record.inventory_code.nil? and record.inventory_code.blank? 
  end

##########################################

  def self.search2(query)
    return scoped unless query

    w = query.split.map do |x|
      "CONCAT_WS(' ', name, inventory_code) LIKE '%#{x}%'"
    end.join(' AND ')
    where(w)
  end
  
  def self.filter2(options)
    sql = scoped
    options.each_pair do |k,v|
      case k
        when :inventory_pool_id
          sql = sql.where(k => v)
      end
    end
    sql
  end

##########################################

  # TODO 2702** before_destroy: check if option_lines.empty?

  def needs_permission?
    false  
  end
  
  def to_s
    name
  end

  # OPTIMIZE we might want a real manufacturer attribute (stored in the db) later on
  def manufacturer
    nil
  end
 
end
 
