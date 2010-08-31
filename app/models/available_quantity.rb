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
end
