class Option < ActiveRecord::Base
  belongs_to :inventory_pool
  has_many :option_lines

  validates_presence_of :inventory_pool, :name

  acts_as_ferret :fields => [ :inventory_code, :name ], :store_class_name => true, :remote => true

  # TODO 2702** before_destroy: check if option_lines.empty?

  def needs_permission?
    false  
  end
  
  def to_s
    name
  end
 
end
 