module Json
  module SupplierHelper

    def hash_for_supplier(supplier, with = nil)
      h = {
        id: supplier.id,
        name: supplier.to_s
      }    
      
      h
    end
  end
end
      