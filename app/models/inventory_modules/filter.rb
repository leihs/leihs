module InventoryModules
  module Filter

    def self.included(base)
      base.class_eval do
        extend(ClassMethods)
      end
    end

    module ClassMethods

      def filter (params, current_inventory_pool = nil)
        
        items = Item.filter params.clone.merge({paginate: "false", all: "true", search_term: nil}), current_inventory_pool

        if [:unborrowable, :retired, :category_id, :in_stock, :incomplete, :broken, :owned, :responsible_id, :unused_models].all? {|param| params[param].blank?}
          options = Option.filter params.clone.merge({paginate: "false", sort: "name", order: "ASC"}), current_inventory_pool
        end

        item_ids = items.select("items.id")

        models = unless params[:unused_models]
            Model.joins(:items).select("DISTINCT models.*").where("items.id IN (#{item_ids.to_sql})")
          else
            model_ids = Model.joins(:items).select("DISTINCT models.id").where("items.id IN (#{item_ids.to_sql})")
            Model.where("models.id NOT IN (#{model_ids.to_sql})") 
        end

        models = models.search(params[:search_term], [:name, :items]) if params[:search_term]
                       
        models = models.order("name ASC")
            
        inventory = (models + (options || [])).
                    sort{|a,b| a.name.strip <=> b.name.strip}

        inventory = inventory.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"

        return inventory
      end

    end

  end
end
