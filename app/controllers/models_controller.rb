class ModelsController < FrontendController

  before_filter :pre_load

  def index( category_id = params[:category_id].to_i, # TODO 18** nested route ?
             start = (params[:start] || 0).to_i,
             limit = (params[:limit] || 25).to_i,
             query = params[:query],
             recent = params[:recent],
             sort = params[:sort] || 'name',
             dir = params[:dir] || 'asc' )

    # OPTIMIZE 21** conditions. avoid +&+ intersections because are breaking paginator, forcing to use Array instead of ActiveRecord
    conditions = ["1"] 
    
    if recent
      models = current_user.orders.sort.collect(&:models).flatten.uniq[start,limit]
      models ||= []
    else
      models = current_user.models
      conditions.first << " AND inventory_pools.id IN (?) AND items.is_borrowable = 1 AND items.parent_id IS NULL AND access_rights.level >= items.required_level"
      conditions << current_inventory_pools 
    end

    if category_id > 0
      category = Category.find(category_id)
      m_ids= (category.children.recursive.to_a << category).collect(&:models).flatten.uniq.collect(&:id)
      conditions.first << " AND models.id IN (?)"
      conditions << m_ids 
    end

    models = models.all(:conditions => conditions)
    # TODO 18** include Templates: models += current_user.templates
    # OPTIMIZE N+1 select problem, :include => :locations
    @models = models.search(query, :page => ((start / limit) + 1), :per_page => limit, :order => sort.to_sym, :sort_mode => dir.downcase.to_sym)
      
    c = @models.total_entries

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
                                                                                      :methods => [[:items_size, @model.id]],
                                                                                      :only => [:id, :name] },
                                                                :images => { :methods => [:public_filename, :public_filename_thumb],
                                                                             :except => [:created_at,
                                                                                         :updated_at] }
                                                                        }
                                                                 ) }
    end
  end

#################################################################

  def chart
    # TODO 04** pass arguments
    c = @model.chart(current_user, @inventory_pool, params[:days_from_today], params[:days_from_start])
#old#    
    redirect_to c
#new#    send_data(c.to_blob, :filename => "model_#{@model.id}.png", :type => 'image/png')
  end

#################################################################

  private
  
  def pre_load
    params[:model_id] ||= params[:id] if params[:id]
    @model = current_user.models.find(params[:model_id]) if params[:model_id]
    @inventory_pool = current_user.inventory_pools.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
  end


end
