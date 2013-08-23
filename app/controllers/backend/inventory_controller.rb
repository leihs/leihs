class Backend::InventoryController < Backend::BackendController

  def index(query = params[:query],
            sort_attr = params[:sort_attr] || 'name',
            sort_dir = params[:sort_dir] || 'ASC',
            page = (params[:page] || 1).to_i,
            per_page = (params[:per_page] || PER_PAGE).to_i,
            category_id = params[:category_id].try(:to_i),
            borrower_user = params[:user_id].try{|x| current_inventory_pool.users.find(x)},
            borrowable = (params[:borrowable] ? !(params[:borrowable] == "false") : nil),
            retired = (params[:retired] == "true" ? true : nil),
            item_filter = params[:filter],
            start_date = params[:start_date].try{|x| Date.parse(x)},
            end_date = params[:end_date].try{|x| Date.parse(x)},
            responsibles = (params[:responsibles] == "true" ? true : nil),
            with = params[:with] ? params[:with].deep_symbolize_keys : {} )
    
    if request.format == :json or request.format == :csv

        scoped_items = if retired
          Item.unscoped.where(Item.arel_table[:retired].not_eq(nil))
        else
          Item # NOTE using default scope, that is {retired => nil}
        end.by_owner_or_responsible(current_inventory_pool)

        # borrowable / unborrowable
        scoped_items = scoped_items.send(borrowable ? :borrowable : :unborrowable) if not borrowable.nil? 

        # categories
        if category_id
          scoped_items = scoped_items.where(:model_id => Model.joins(:categories).where(:"model_groups.id" => [Category.find(category_id)] + Category.find(category_id).descendants))
        end
    
        unless item_filter.nil?
          if item_filter[:flags]
            [:in_stock, :incomplete, :broken].each do |k|
              scoped_items = scoped_items.send(k) if item_filter[:flags].include?(k.to_s)
            end
            scoped_items = scoped_items.where(:owner_id => current_inventory_pool) if item_filter[:flags].include?(:owned.to_s)
          end
          scoped_items = scoped_items.where(:inventory_pool_id => item_filter[:responsible_id]) if item_filter[:responsible_id]
        end 
         
        options = if borrowable != false and retired.nil? and item_filter.nil? and category_id.nil?
          current_inventory_pool.options.search(query, [:name]).order("#{sort_attr} #{sort_dir}")
        else
          []
        end
    end

    respond_to do |format|
      format.html
      format.json {
        item_ids = scoped_items.select("items.id")
        models = Model.
                  select("DISTINCT models.*").
                  search(query, [:name, :items]).
                  order("#{sort_attr} #{sort_dir}")
        models = models.joins(:items).where("items.id IN (#{item_ids.to_sql})") 
        # TODO migrate strip directly to the database, and strip on before_validation
        models_and_options = (models + options).
                             sort{|a,b| a.name.strip <=> b.name.strip}.
                             paginate(:page => page, :per_page => PER_PAGE)
        with.deep_merge!({ :items => {:scoped_ids => item_ids, :query => query} })
        hash = { inventory: {
                    entries: view_context.hash_for(models_and_options, with),
                    pagination: {
                      current_page: models_and_options.current_page,
                      per_page: models_and_options.per_page,
                      total_pages: models_and_options.total_pages,
                      total_entries: models_and_options.total_entries
                    }
                  },
                } 

        if responsibles
          responsibles_for_items = InventoryPool.joins(:items).where("items.id IN (#{item_ids.to_sql})").select("DISTINCT inventory_pools.*")
          hash.merge!({responsibles: view_context.hash_for(responsibles_for_items)})
        end
        
        render :json => hash
      } 
      format.csv {
        require 'csv'
        items = scoped_items.search(query)
        csv_string = CSV.generate({ :col_sep => ";", :quote_char => "\"", :force_quotes => true }) do |csv|
          csv << Item.csv_header
          items.each do |i|
            csv << i.to_csv_array unless i.nil? # How could an item ever be nil?
          end
          options.each do |o|
            csv << o.to_csv_array unless o.nil? # How could an item ever be nil?
          end
        end
       
        send_data csv_string, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=#{_("Items-leihs")}.csv"
      }
    end
  end
end