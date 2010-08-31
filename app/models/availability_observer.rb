class AvailabilityObserver < ActiveRecord::Observer
  observe :item, :model, :access_right

  ##############################################################
  #
  # Classes for observing and reacting to changes of specific records
  #
  ##############################################################
  class ModelObserver
    def self.after_update(record)
      # TODO: if you let the groups.feature test run, you'll notice that
      #       model.update gets called far to often. There seems to be
      #       oportunity to reduce the number of calls during "creation"
      #       of a model
    end
  end

  class ItemObserver
    def self.after_create(record)
      AvailabilityChange.add(record.model, record.inventory_pool) if record.inventory_pool
    end
    
    def self.after_update(record)
      if record.changed.include? 'inventory_pool'
        if record.inventory_pool_was.nil?
          AvailabilityChange.add(record.model, record.inventory_pool)
        else
          # TODO:
          raise "Not implemented"
        end
      end
    end    
  end

  # TODO: this should probably go into AccessRight itself since it
  #       is too tightly coupled to it (i.e. it needs to know specific
  #       business details to work right)
  class AccessRightObserver
    # TODO: we need to handle changes from admin to user and back
    def self.before_save(record)
      if role.name != 'admin'
        record.inventory_pool.add_to_general_group(record.user)
      end
    end    

    def self.before_destroy(record)
      # TODO: this actually should never happen, since access rights
      # seem only to get disabled and not deleted
      raise "Not implemented"
    end    

  end

  #############################################
  # 
  # dispatchers that observe changes to records
  #
  #############################################
  def before_save(record)
    redirect_to_responsible_observer_method "before_save", record
  end

  def before_destroy(record)
    redirect_to_responsible_observer_method "before_destroy", record
  end

  def after_create(record)
    redirect_to_responsible_observer_method "after_create", record
  end
  
  def after_update(record)
    redirect_to_responsible_observer_method "after_update", record
  end

###################################################

private

  # given a method and a record call the method in the observer class
  # that's responsible for observing that kind of record
  #
  def redirect_to_responsible_observer_method(method_name, record)
    klass = observer_class(record)
    if klass.methods.include? method_name
       klass.send method_name, record
    end    
  end
  
  # returns the class of the observer responsible for reacting on
  # changes of records of that type
  #
  def observer_class( record )
    return "AvailabilityObserver::#{record.class.name}Observer".constantize
  end
end
