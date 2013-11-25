module VisitModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, inventory_pool = nil)
        visits = inventory_pool.nil? ? Visit.all : inventory_pool.visits
        visits = visits.where Visit.arel_table[:action].eq(params[:type]) if params[:type]
        visits = visits.where(:action => params[:actions]) if params[:actions]
        visits = visits.search(params[:search_term]) unless params[:search_term].blank?
        visits = visits.where Visit.arel_table[:date].lteq(params[:date]) if params[:date] and params[:date_comparison] == "lteq"
        visits = visits.where Visit.arel_table[:date].eq(params[:date]) if params[:date] and params[:date_comparison] == "eq"
        visits = visits.where(Visit.arel_table[:date].gt(params[:range][:start_date])) if params[:range] and params[:range][:start_date]
        visits = visits.where(Visit.arel_table[:date].lt(params[:range][:end_date])) if params[:range] and params[:range][:end_date]
        visits = visits.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"
        return visits
      end

    end

  end
end
