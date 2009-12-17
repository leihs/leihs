class Category < ModelGroup

  acts_as_ferret :fields => [ :name ], :store_class_name => true, :remote => true

  # for ext_json serialization
  def real_id
    id
  end
  
end
