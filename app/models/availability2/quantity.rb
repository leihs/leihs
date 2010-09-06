module Availability2
  class Quantity < ActiveRecord::Base
    set_table_name "availability_quantities"

    belongs_to :availability_change, :class_name => "Availability2::Change"
    belongs_to :group
  
    validates_presence_of :availability_change_id
    validates_presence_of :group_id
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
end