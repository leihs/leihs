class Category < ModelGroup

  define_index do
    indexes :name
    set_property :delta => true
  end

  # for ext_json serialization
  def real_id
    id
  end
  
end
