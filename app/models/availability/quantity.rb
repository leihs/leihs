module Availability
  class Quantity < ActiveRecord::Base
    set_table_name "availability_quantities"

    belongs_to :change
    belongs_to :group
  
    validates_presence_of :change_id
#tmp#2    validates_presence_of :group_id
    validates_presence_of :in_quantity
    validates_presence_of :out_quantity
    
    validates_uniqueness_of :group_id, :scope => :change_id
  
    serialize :out_document_lines, Array #tmp#5 has_and_belongs_to_many :out_document_lines
    
    # TODO
#    def document
#      || []
#    end
  
    def add_document(d)
      self.out_document_lines ||= []
      out_document_lines << {:type => d.class.to_s, :id => d.id} #tmp#5
      self
    end
    
    def remove_document(d)
      self.out_document_lines ||= []
      out_document_lines.delete({:type => d.class.to_s, :id => d.id}) #tmp#5
      self
    end
  end
end