# Options are things that can be borrowed, however don't have
# their own barcode and thus dont have individual identities
# (contrary to #Item s) and thus can be given out by the
# manager in arbitrary quantities. Also Options are not an
# instance of some #Model as #Item s are.
#
class Option < ActiveRecord::Base
  belongs_to :inventory_pool
  has_many :option_lines

  validates_presence_of :inventory_pool, :name
  validates_uniqueness_of :inventory_code, :scope => :inventory_pool_id, :unless => Proc.new { |record| record.inventory_code.blank? }

  before_validation do |record|
    record.inventory_code = nil if !record.inventory_code.nil? and record.inventory_code.blank? 
  end

  define_index do
    indexes :inventory_code
    indexes :name
    
    has :inventory_pool_id
    
    set_property :delta => true
  end

  # TODO 2702** before_destroy: check if option_lines.empty?

  def needs_permission?
    false  
  end
  
  def to_s
    name
  end
 
end
 