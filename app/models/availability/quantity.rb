# == Schema Information
#
# Table name: availability_quantities
#
#  id           :integer(4)      not null, primary key
#  change_id    :integer(4)
#  group_id     :integer(4)
#  in_quantity  :integer(4)      default(0)
#  out_quantity :integer(4)      default(0)
#

# == Schema Information
#
# Table name: availability_quantities
#
#  id           :integer(4)      not null, primary key
#  change_id    :integer(4)
#  group_id     :integer(4)
#  in_quantity  :integer(4)      default(0)
#  out_quantity :integer(4)      default(0)
#
module Availability
  class Quantity < ActiveRecord::Base
    set_table_name "availability_quantities"

    belongs_to :change
    belongs_to :group, :class_name => "::Group"
  
#tmp#10    validates_presence_of :change_id
#tmp#2    validates_presence_of :group_id
    validates_presence_of :in_quantity
    validates_presence_of :out_quantity
    
#tmp#10    validates_uniqueness_of :group_id, :scope => :change_id

    serialize :out_document_lines
    def append_to_out_document_lines(type, id)
      self.out_document_lines ||= {}
      self.out_document_lines[type] ||= []
      out_document_lines[type] << id unless out_document_lines[type].include?(id) 
    end    
    def document_lines
      r = []
      out_document_lines.each_pair do |k,v|
        r += k.constantize.find(v)
      end
      r
    end
    
  end

end
