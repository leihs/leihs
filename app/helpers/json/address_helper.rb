module Json
  module AddressHelper

    def hash_for_address(address, with = nil)
      h = {
        id: address.id,
        street: address.street,
        zip_code: address.zip_code,
        city: address.city,
        country_code: address.country_code
      } 
      
      # TODO
      # latitude: address.latitude
      # longitude: address.longitude
      
      h
    end
  end
end
      