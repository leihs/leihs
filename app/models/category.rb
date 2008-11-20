class Category < ModelGroup

  acts_as_ferret :fields => [ :name ], :store_class_name => true, :remote => true

  
end
