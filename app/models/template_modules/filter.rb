module TemplateModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, current_inventory_pool)
        templates = current_inventory_pool.templates
        templates = templates.search(params[:search_term]) unless params[:search_term].blank?
        templates = templates.order("#{params[:sort] || 'name'} #{params[:order] || 'ASC'}")
        templates = templates.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min)
        return templates
      end

    end

  end
end
