class AvailabilityObserver < ActiveRecord::Observer
  observe :item, :model

  class ModelObserver
    def self.after_update(record)
      puts "**** Hello ModelObserver"
    end
  end

  class ItemObserver
    def self.after_update(record)
      puts "**** Hello ItemObserver"
#      self.inventory_pool.add_to_group("General", self.model)
   end    
  end

  def after_update(record)
    observer_class(record).after_update(record)
  end

  # returns the class of the observer responsible for reacting on
  # changes of records of that type
  def observer_class( record )
    return "AvailabilityObserver::#{record.class.name}Observer".constantize
  end
end
