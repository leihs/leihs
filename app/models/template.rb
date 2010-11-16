# == Schema Information
#
# Table name: model_groups
#
#  id         :integer(4)      not null, primary key
#  type       :string(255)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  delta      :boolean(1)      default(TRUE)
#

class Template < ModelGroup
  
  # TODO 12** belongs_to :inventory_pool through
  # TODO 12** validates belongs_to 1 and only 1 inventory pool
  # TODO 12** validates all models are present to current inventory_pool
  # TODO 12** has_many :models through
  
  define_index do
    indexes :name

    indexes :id # 0501 forcing indexer even if blank attributes, validates_presence_of :name ???

    has inventory_pools(:id), :as => :inventory_pool_id
    
    set_property :delta => true
  end
  
  ####################################################################################
  
  
  # TODO merge model_links with same models and sum quantities
  
  def add_to_document(document, user_id, quantity = nil, start_date = nil, end_date = nil, inventory_pool = nil)
    model_links.each do |ml|
      document.add_line(ml.quantity, ml.model, user_id, start_date, end_date, inventory_pool)
    end
  end  
  
  def total_quantity
    model_links.collect(&:quantity).sum
  end
  
  
end

