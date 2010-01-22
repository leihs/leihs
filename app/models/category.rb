class Category < ModelGroup

  define_index do
    indexes :name, :sortable => true

    indexes :id # 0501 forcing indexer even if blank attributes, validates_presence_of :name ???
    
    # TODO 0501 has :parent_id, :child_id
    has inventory_pools(:id), :as => :inventory_pool_id
    
    set_property :delta => true
  end

  # TODO 0501 doesn't work!
  default_sphinx_scope :default_search
  sphinx_scope(:default_search) { {:order => :name, :sort_mode => :asc} }

#########################################################

  # for ext_json serialization
  def real_id
    id
  end
  
end
