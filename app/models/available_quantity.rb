class AvailableQuantity < ActiveRecord::Base
  belongs_to :availability_change
  belongs_to :group

#old#  validates_presence_of :status_const
  validates_presence_of :availability_change_id
  validates_presence_of :group_id
#old#  validates_presence_of :quantity
  validates_presence_of :in_quantity
  validates_presence_of :out_quantity

  serialize :documents, Array

  def add_document(d)
    self.documents ||= []
    documents << {:type => d.class.to_s, :id => d.id}
    self
  end
  
  def remove_document(d)
    self.documents ||= []
    documents.delete({:type => d.class.to_s, :id => d.id})
    self
  end


#old#
#  AVAILABLE    = 1
#  BORROWED     = 2
#  UNBORROWABLE = 3
#
#  STATUS = {_("Available") => AVAILABLE, _("Borrowed") => BORROWED, _("Unborrowable") => UNBORROWABLE }
#
#  def status_string
#    n = STATUS.index(status_const)
#    n.nil? ? status_const : n
#  end
#
#  def AvailableQuantity.status_from( status_string )
#    normalized_status = status_string[0,1].upcase + status_string[1..-1].downcase
#    return STATUS[normalized_status]
#  end
#
#  named_scope :available,    :conditions => {:status_const => AvailableQuantity::AVAILABLE}
#  named_scope :borrowed,     :conditions => {:status_const => AvailableQuantity::BORROWED}
#  named_scope :unborrowable, :conditions => {:status_const => AvailableQuantity::UNBORROWABLE}

end
