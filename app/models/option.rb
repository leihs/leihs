class Option < ActiveRecord::Base
  belongs_to :inventory_pool
  has_many :option_lines

  validates_presence_of :inventory_pool, :name

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
 