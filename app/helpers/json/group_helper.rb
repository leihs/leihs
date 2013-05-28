module Json
  module GroupHelper

    def hash_for_group(group, with = nil)
      h = {
        id: group.id,
        name: group.name
      }    
      
      h
    end
  end
end
      