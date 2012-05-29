module Json
  module OptionHelper

    def hash_for_option(option, with = nil)
      h = {
        type: option.class.to_s.underscore,
        id: option.id,
        name: option.name
      }

      if with ||= nil
        [:inventory_code, :price].each do |k|
          h[k] = option.send(k) if with[k]
        end
      end
      
      h
    end

  end
end
