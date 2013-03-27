module Json
  module FieldHelper

    def hash_for_field(field, with = nil)
      field.as_json :current_inventory_pool => current_inventory_pool
    end
  end
end
