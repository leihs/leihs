class ModelsController < FrontendController

  def index( category_id = params[:category_id].to_i, # TODO 18** nested route ?
             start = (params[:start] || 0).to_i,
             limit = (params[:limit] || 25).to_i,
             query = params[:query],
             recent = params[:recent],
             sort =  "models.#{(params[:sort] || 'name')}",
             dir =  params[:dir] || 'ASC' )

    # OPTIMIZE 21** conditions. avoid +&+ intersections because are breaking paginator, forcing to use Array instead of ActiveRecord
    conditions = ["1"] 
    
    if recent
      models = current_user.orders.sort.collect(&:models).flatten.uniq[start,limit]
      models ||= []
    else
#old#      models = current_user.models & current_inventory_pools.collect(&:models).flatten.uniq 
#old#2      models = current_user.models.all(:conditions => ["inventory_pools.id IN (?)", current_inventory_pools])
      models = current_user.models 
      conditions.first << " AND inventory_pools.id IN (?)"
      conditions << current_inventory_pools 
    end

    if category_id > 0
      category = Category.find(category_id)
#old#   models = (category.children.recursive.to_a << category).collect(&:models).flatten & models
      m_ids= (category.children.recursive.to_a << category).collect(&:models).flatten.uniq.collect(&:id)
      conditions.first << " AND models.id IN (?)"
      conditions << m_ids 
    end

    # TODO 09** merge paginate to search
    unless query.blank?
      # TODO 18** include Templates: models += current_user.templates
      models = models.all(:conditions => conditions)
      @models = models.search(query, {:offset => start, :limit => limit}, {:order => sanitize_order(sort, dir)})
      
      c = @models.total_hits
    else
#old#    @models = models.paginate :page => ((start / limit) + 1), :per_page => limit, :order => "#{sort} #{dir}"
#old#2    @models = Model.paginate :page => ((start / limit) + 1), :per_page => limit, :order => "#{sort} #{dir}", :conditions => ["models.id IN (?)", models.collect(&:id)] 
      @models = models.paginate :page => ((start / limit) + 1), :per_page => limit, :order => sanitize_order(sort, dir), :conditions => conditions
          # OPTIMIZE N+1 select problem, :include => :locations
      c = @models.total_entries
    end

    respond_to do |format|
      format.ext_json { render :json => @models.to_ext_json(:class => "Model",
                                                            :count => c,
                                                            :except => [ :internal_description,
                                                                         :info_url,
                                                                         :maintenance_period,
                                                                         :created_at,
                                                                         :updated_at ],
                                                            :include => {
                                                                :inventory_pools => { :records => current_inventory_pools,
                                                                                      :except => [:description,
                                                                                                  :logo_url,
                                                                                                  :contract_url,
                                                                                                  :contract_description,
                                                                                                  :created_at,
                                                                                                  :updated_at] } }
                                                                 ) }
    end
  end  

#######################################################  
  
  def show
    @model = current_user.models.find(params[:id])
    
    @models = [@model]
    c = @models.size
    respond_to do |format|
      format.ext_json { render :json => @models.to_ext_json(:class => "Model",
                                                            :count => c,
                                                            :except => [ :internal_description,
                                                                         :info_url,
                                                                         :maintenance_period,
                                                                         :created_at,
                                                                         :updated_at ],
                                                            :methods => [[:chart, current_user]],
                                                            :include => {
                                                                :package_items => { :except => [:created_at,
                                                                                                :updated_at,
                                                                                                :parent_id,
                                                                                                :model_id],
                                                                                    :include => [:model]},
                                                                :properties => { :except => [:created_at,
                                                                                             :updated_at] },
                                                                :accessories => { :except => [:model_id] },
                                                                :compatibles => { :records => current_inventory_pools.collect(&:models).flatten.uniq,
                                                                                  :except => [:created_at,
                                                                                             :updated_at,
                                                                                             :model_id,
                                                                                             :compatible_id] },
                                                                :inventory_pools => { :records => current_inventory_pools,
                                                                                      :methods => [[:items_size, @model.id], # OPTIMIZE include availability for today?
                                                                                                   [:name_and_items_size, @model.id]], # TODO 01** provide name_and_items_size directly in extjs
                                                                                      :only => [:id, :name] },
                                                                :images => { :methods => [:public_filename_thumb],
                                                                             :except => [:created_at,
                                                                                         :updated_at] }
                                                                        }
                                                                 ) }
    end
  end

end
