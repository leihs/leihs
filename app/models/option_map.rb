class OptionMap < ActiveRecord::Base
  belongs_to :inventory_pool

  acts_as_ferret :fields => [ :barcode, :text ], :store_class_name => true, :remote => true

end
 