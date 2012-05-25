module Json
  module OptionHelper

    def hash_for_option(option, with = nil)
      h = {
        id: option.id,
        name: option.name,
        type: option.class.to_s.underscore
      }
      
      h
    end

  end
end
