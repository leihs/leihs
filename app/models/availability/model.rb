module Availability
  module Model

    def availability_in(inventory_pool)
      Availability::Main.new(model: self, inventory_pool: inventory_pool)
    end

  end
end
