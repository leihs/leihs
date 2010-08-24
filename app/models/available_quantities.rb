class AvailableQuantities < ActiveRecord::Base
  belongs_to :availability_change
  belongs_to :group

  validates_presence_of :status_const
  validates_presence_of :availability_change_id
  validates_presence_of :group_id
  validates_presence_of :quantity
  
  AVAILABLE    = 1
  BORROWED     = 2
  UNBORROWABLE = 3

  STATUS = {_("Available") => AVAILABLE, _("Borrowed") => BORROWED, _("Unborrowable") => UNBORROWABLE }

  def status_string
    n = STATUS.index(status_const)
    n.nil? ? status_const : n
  end

  def AvailableQuantities.status_from( status_string )
    normalized_status = status_string[0,1].upcase + status_string[1..-1].downcase
    return STATUS[normalized_status]
  end

  named_scope :available,    :conditions => {:status_const => AvailableQuantities::AVAILABLE}
  named_scope :borrowed,     :conditions => {:status_const => AvailableQuantities::BORROWED}
  named_scope :unborrowable, :conditions => {:status_const => AvailableQuantities::UNBORROWABLE}

end
