class Option < ActiveRecord::Base
  belongs_to :inventory_pool
  has_many :option_lines

  validates_presence_of :inventory_pool

  define_index do
    indexes :inventory_code
    indexes :name
    has :id
    set_property :delta => true
  end

  # TODO 2702** before_destroy: check if option_lines.empty?

  def to_s
    name
  end
 
end
 