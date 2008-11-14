class Category < ModelGroup

  acts_as_ferret :fields => [ :name ], :remote => true

  
end
