class Category < ModelGroup

  define_index do
    indexes :name, :sortable => true
     # TODO 0501 has :parent_ids, :child_ids
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
