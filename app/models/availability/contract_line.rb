module Availability
  module ContractLine

    attr_accessor :allocated_group_id
    
#################################

    def available?
      b = if end_date < Date.today # check if it was never handed over
        false
      elsif status == :unsubmitted
        if user.timeout?
          same_contract_summed_quantity = user.contract_lines.where(inventory_pool_id: inventory_pool_id,
                                                                    status: status,
                                                                    model_id: model_id).where("start_date <= ? AND end_date >= ?", end_date, start_date).sum(:quantity)
          (maximum_available_quantity >= same_contract_summed_quantity)
        else
          # the unsubmitted contract_lines are also considered as running_lines for the availability, then we sum up again the current contract_line quantity (preventing self-blocking problem)
          (maximum_available_quantity + quantity >= quantity)
        end
      elsif is_a?(OptionLine)
        true
      elsif not inventory_pool.running_lines.detect {|x| x == self} # NOTE doesn't work with include?(self) because are running_lines
        # we use array select instead of sql where condition to fetch once all document_lines during the same request, instead of hit the db multiple times
        true
      else
        # if an item is already assigned, but the start_date is in the future, we only consider the real start-end range dates
        a = model.availability_in(inventory_pool)
        group_id = a.document_lines.detect {|x| x == self}.allocated_group_id # NOTE doesn't work self.allocated_group_id because is not a running_line
        
        # first we check if the user is member of the allocated group (if false, then it's a soft-overbooking)
        (group_id.nil? or self.user.group_ids.include?(group_id)) and
          # then we check if all changes related to the time range and allocated group are non-negative (then it's a real-overbooking)
          a.changes.between(start_date, end_date).all? {|k,v| v[group_id][:in_quantity] >= 0}
      end

      # OPTIMIZE
      if b and [:unsubmitted].include? status
        b = (b and inventory_pool.is_open_on?(start_date) and inventory_pool.is_open_on?(end_date)) 
        b = (b and not user.access_right_for(inventory_pool).suspended?)
      end

      b
    end

    def maximum_available_quantity
      model.availability_in(inventory_pool).maximum_available_in_period_for_groups(start_date, end_date, group_ids)
    end

  end
end
