module ContractLineModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, inventory_pool = nil)
        contract_lines = if inventory_pool 
            inventory_pool.contract_lines
          else
            ContractLine.scoped
        end

        contract_lines = contract_lines.where(contract_id: params[:contract_ids]) if params[:contract_ids]
        contract_lines = contract_lines.where(id: params[:ids]) if params[:ids]

        return contract_lines
      end

    end

  end
end


