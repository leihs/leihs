module ItemModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, current_inventory_pool = nil)
        items = params[:all] ? Item.unscoped : Item.scoped
        items = items.by_owner_or_responsible current_inventory_pool if current_inventory_pool
        items = items.where(Item.arel_table[:retired].not_eq(nil)) if params[:retired]
        items = items.borrowable if params[:borrowable]
        items = items.unborrowable if params[:unborrowable] 
        items = items.where(:model_id => Model.joins(:categories).where(:"model_groups.id" => [Category.find(params[:category_id])] + Category.find(params[:category_id]).descendants)) if params[:category_id]
        items = items.where(:id => params[:ids]) if params[:ids]
        items = items.where(:id => params[:id]) if params[:id]
        items = items.where(:parent_id => params[:package_ids]) if params[:package_ids]
        items = items.where(:parent_id => nil) if params[:not_packaged]
        items = items.in_stock if params[:in_stock]
        items = items.incomplete if params[:incomplete]
        items = items.broken if params[:broken]
        items = items.where(:owner_id => current_inventory_pool) if params[:owned]
        items = items.where(:inventory_pool_id => params[:responsible_id]) if params[:responsible_id]
        items = items.where(:inventory_code => params[:inventory_code]) if params[:inventory_code]
        items = items.where(:model_id => params[:model_ids]) if params[:model_ids]
        items = items.in_stock if params[:in_stock]
        items = items.search(params[:search_term]) unless params[:search_term].blank?
        items = items.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"
        return items
      end

    end

  end
end
