# A DocumentLine is a line in a #Document and
# serves as an abstract superclass for #OrderLine
# and #ContractLine.
#
class DocumentLine < ActiveRecord::Base
  include Availability::DocumentLine
  self.abstract_class = true

###############################################  

  belongs_to :purpose
  
  # TODO this is a fallback, to be removed right on running the migration 20120424080001_remove_purpose_columns.rb 
  def purpose_with_fallback
    r = purpose_without_fallback
    r ||= (document_purpose = document.read_attribute(:purpose)) ? Purpose.new(:description => document_purpose) : nil 
    r
  end
  alias_method_chain :purpose, :fallback

###############################################  
  
  before_validation :set_defaults, :on => :create
  validate :date_sequence  
  validates_numericality_of :quantity, :greater_than_or_equal_to => 0, :only_integer => true 

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
    # r += self.errors.full_messages.uniq
    return r
  end

  def visits_on_open_date?
    inventory_pool.is_open_on(start_date) and inventory_pool.is_open_on(end_date)
  end

  # custom valid? method
  def complete?
    self.valid? and self.available?
  end

  # TODO 04** merge in complete? 
  def complete_tooltip
    r = ""
    r += _("not valid. ") unless self.valid? # TODO 04** self.errors.full_messages.uniq
    r += _("not available. ") unless self.available?
    return r
  end

  # TODO 04** merge in available? 
  def available_tooltip
    r = ""
    r += _("quantity not available. ") unless available?
    r += _("inventory pool is closed on start_date. ") unless inventory_pool.is_open_on?(start_date)
    r += _("inventory pool is closed on end_date. ") unless inventory_pool.is_open_on?(end_date)
    return r
  end

  # abstract method - implemented by ContractLine
  def is_reserved?
    false
  end
###############################################  

  def price
    (item.price || 0) * quantity
  end

  private
  
  def set_defaults
    self.start_date ||= Date.today
    self.end_date ||= Date.today
  end

  def date_sequence
    # OPTIMIZE strange behavior: in some cases, this error raises when shouldn't 
    errors.add(:base, _("Start Date must be before End Date")) if end_date < start_date
   #TODO: Think about this a little bit more.... errors.add(:base, _("Start Date cannot be a past date")) if start_date < Date.today
  end


end
