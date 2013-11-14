module ContractModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, user = nil, inventory_pool = nil)
        contracts = if user 
            user.contracts 
          elsif inventory_pool
            inventory_pool.contracts
          else
            Contract.scoped
        end
        contracts = contracts.search(params[:search_term]) unless params[:search_term].blank?
        contracts = contracts.where(:status => params[:status]) if params[:status]
        contracts = contracts.where(:id => params[:ids]) if params[:ids]
        contracts = contracts.where(Contract.arel_table[:created_at].gt(params[:range][:start_date])) if params[:range] and params[:range][:start_date]
        contracts = contracts.where(Contract.arel_table[:created_at].lt(params[:range][:end_date])) if params[:range] and params[:range][:end_date]
        contracts = contracts.order(Contract.arel_table[:created_at].desc)
        contracts = contracts.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"
        return contracts
      end

    end

  end
end
