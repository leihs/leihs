module Availability
  class Quantity

    attr_accessor :group_id
    attr_accessor :in_quantity
    attr_accessor :out_quantity
    attr_accessor :out_document_lines
    # out_document_lines = { "ItemLine"        => [222, 432,  ...],
    #                        "AnotherKindLine" => [987, 2232, ...],
    #                      }

    def group
      if @group_id
        ::Group.find @group_id
      else
        Group::GENERAL_GROUP_ID
      end
    end

    def initialize(attr)
      @group_id = attr[:group_id]
      @in_quantity = attr[:in_quantity] || 0
      @out_quantity = attr[:out_quantity] || 0
      @out_document_lines = attr[:out_document_lines] || {}
    end
      
    def append_to_out_document_lines(type, id)
      @out_document_lines[type] ||= []
      @out_document_lines[type] << id unless @out_document_lines[type].include?(id) 
    end

    def document_lines
      r = []
      @out_document_lines.each_pair do |k,v|
        r += case k
        when "OrderLine"
          k.constantize.find(v, :include => {:order => :user})
        else 
          k.constantize.find(v, :include => {:contract => :user}) # TODO remove our Item#find and :include => [{:contract => :user}, :item]
        end 
      end
      r
    end
    
  end

end
