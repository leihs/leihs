module Availability2
  class Quantity < ActiveRecord::Base
    set_table_name "availability_quantities"

    belongs_to :change
    belongs_to :group
  
    validates_presence_of :change_id
#tmp#2    validates_presence_of :group_id
    validates_presence_of :in_quantity
    validates_presence_of :out_quantity
  
    serialize :documents, Array
    
    # TODO
#    def document
#      || []
#    end
  
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
end