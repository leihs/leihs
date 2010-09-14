# A DocumentLine is a line in a #Document and
# serves as an abstract superclass for #OrderLine
# and #ContractLine.
#
class DocumentLine < ActiveRecord::Base
  include Availability::DocumentLine
  
  self.abstract_class = true
  
  before_validation_on_create :set_defaults
  validate :date_sequence  
  validates_numericality_of :quantity, :greater_than_or_equal_to => 0, :only_integer => true 

#old-availability#
#  before_create do |record|
#    record.cached_available = nil
#  end

#old-availability#
#  # expires cached_available attributes. See #available?
#  #
#  before_save do |record|
#    # If we were updating the cached_availablity field of a #DocumentLine *only*, then
#    # we do not want to trigger an update, since no real property of the line has
#    # changed. We only want to trigger an updaten on changes of all the other fields.  
#    unless record.changed == [ "cached_available" ]
#      record.void_cached_available_flag_of_same_model_and_in_same_ip
#    end
#  end
#
#  before_destroy :void_cached_available_flag_of_same_model_and_in_same_ip

###############################################  

#old-availability#
#  # this is a private method
#  def void_cached_available_flag_of_same_model_and_in_same_ip
#    # we do not want unsubmitted #Orders to have any influence on the state of foreign DocumentLines
#    if self.is_a?(OrderLine) and self.order.status_const == Order::UNSUBMITTED
#      ActiveRecord::Base.connection.update "UPDATE order_lines " \
#                                              "SET cached_available = NULL " \
#                                              "WHERE model_id = '#{self.model_id}' " \
#                                                "AND order_id = '#{self.order_id}' "
#    else
#      # TODO don't care about backup 
#      [ "contract", "order"].each do |document|
#        # we are JOINing the contract_ or order_lines table with the orders/contracts table
#        # in order to beeing able to compare with the inventory pool id, which lives in the
#        # orders/contracts table
#        #
#        # TODO: the update is too broad. We should limit it to orders containing our period
#        ActiveRecord::Base.connection.update "UPDATE #{document}_lines,#{document}s " \
#                                                "SET #{document}_lines.cached_available = NULL " \
#                                                "WHERE #{document}_lines.model_id = '#{self.model_id}' " \
#                                                  "AND #{document}_lines.#{document}_id = #{document}s.id " \
#                                                  "AND #{document}s.inventory_pool_id = '#{self.inventory_pool.id}'"
#      end
#    end
#  end

  # compares two objects in order to sort them
  def <=>(other)
    [self.start_date, self.model.name] <=> [other.start_date, other.model.name]
  end

###############################################  

  # TODO 03** merge here available_tooltip and complete_tooltip
  def tooltip
    r = ""
    r += self.available_tooltip
    r += "<br/>"
    r += self.complete_tooltip
    # TODO 03** include errors?
    # r += self.errors.full_messages
    return r
  end

  # custom valid? method
  def complete?
    self.valid? and self.available?
  end

  # TODO 04** merge in complete? 
  def complete_tooltip
    r = ""
    r += _("not valid. ") unless self.valid? # TODO 04** self.errors.full_messages
    r += _("not available. ") unless self.available?
    return r
  end

  # :nodoc: in case we've allready calculated whether an #DocumentLine instance is
  #         available then reuse it. Otherwise recalculate and save it. In case the
  #         the #DocumentLine is changed, then we need to drop the cached values of
  #         the other #DocumentLines with the same #Model and inside the same
  #         #InventoryPool. See #before_save.
  # TODO: recheck - the numbers of updates done don't add up!
#old-availability#
#  def available?
#    if self.cached_available.nil?
#      self.cached_available = (maximum_available_quantity >= quantity)
#      save
#    end
#    self.cached_available
#  end

#old-availability#
#  def maximum_available_quantity
#    model.maximum_available_in_period_for_document_line(start_date, end_date, self) # TODO + quantity
#  end

  # TODO 04** merge in available? 
  def available_tooltip
    r = ""
    r += _("quantity not available. ") unless available?
    r += _("inventory pool is closed on start_date. ") unless inventory_pool.is_open_on?(start_date)
    r += _("inventory pool is closed on end_date. ") unless inventory_pool.is_open_on?(end_date)
    return r
  end

###############################################  

  private
  
  def set_defaults
    self.start_date ||= Date.today
    self.end_date ||= Date.today
  end

  def date_sequence
    # OPTIMIZE strange behavior: in some cases, this error raises when shouldn't 
    errors.add_to_base(_("Start Date must be before End Date")) if end_date < start_date
   #TODO: Think about this a little bit more.... errors.add_to_base(_("Start Date cannot be a past date")) if start_date < Date.today
  end


end
