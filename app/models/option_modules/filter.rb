module OptionModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, inventory_pool = nil)
        options = inventory_pool ? inventory_pool.options : Option.all
        options = options.search(params[:search_term], [:name]) unless params[:search_term].blank?
        options = options.where(:id => params[:ids]) if params[:ids]
        options = options.order("#{params[:sort]} #{params[:order]}") if params[:sort] and params[:order]
        options = options.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"
        return options
      end

    end

  end
end
