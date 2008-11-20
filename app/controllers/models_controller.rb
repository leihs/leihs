class ModelsController < FrontendController

  # TODO prevent sql injection
  def index( category_id = params[:category_id], # TODO 18** nested route ?
             start = (params[:start] || 0).to_i,
             limit = (params[:limit] || 25).to_i,
             query = params[:query],
             recent = params[:recent],
             sort =  "models.#{(params[:sort] || 'name')}",
             dir =  params[:dir] || 'ASC' )

    if recent
      models = current_user.orders.sort.collect(&:models).flatten.uniq[start,limit]
      models ||= []
    else
      models = current_user.models.all(:conditions => ["inventory_pools.id IN (?)", current_inventory_pools]) 
    end

    if category_id
#old# @models = Category.find(category_id).models.find(:all, :offset => start, :limit => limit, :order => "#{sort} #{dir}") & current_user.models
#old# c = (Category.find(category_id).models & current_user.models).size
      category = Category.find(category_id)
      models = (category.children.recursive.to_a << category).collect(&:models).flatten & models #old# current_user.models.all(:conditions => ["inventory_pools.id IN (?)", current_inventory_pools])
    end

    unless query.blank?
#old#
#      @models = current_user.models.find_by_contents(query, {:offset => start,
#                                                   :limit => limit,
#                                                   :order => "#{sort} #{dir}"},
#                                                   :conditions => ["inventory_pools.id IN (?)", current_inventory_pools])
      # TODO 18** scope search to current category selection
      # TODO 18** include Templates: models += current_user.templates
#old#      models = current_user.models & current_inventory_pools.collect(&:models).flatten.uniq 
      @models = models.search(query, {:offset => start, :limit => limit}, {:order => "#{sort} #{dir}"})
      
      # TODO fix total_hits with has_many
      c = @models.total_hits
    else
#old#
#      @models = current_user.models.find(:all,
#                                         :offset => start,
#                                         :limit => limit,
#                                         :order => "#{sort} #{dir}",
#                                         :conditions => ["inventory_pools.id IN (?)", current_inventory_pools])
#      # TODO fix 
#      c = current_user.models.count(:all,
#                                    :conditions => ["inventory_pools.id IN (?)", current_inventory_pools])

    # TODO 18** sort
    @models = models.paginate :page => ((start / limit) + 1), :per_page => limit, :order => "#{sort} #{dir}"
    c = models.size
    end

    respond_to do |format|
      format.ext_json { render :json => @models.to_ext_json(:class => "Model",
                                                            :count => c,
                                                            :except => [ :maintenance_period,
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

  # OPTIMIZE interesections
  def categories(id = params[:node].to_i)
    if id == 0 
      c = Category.roots
#      c = current_user.categories.roots
#      c = current_user.all_categories & Category.roots
    else
      c = Category.find(id).children
#      c = current_user.categories & Category.find(id).children # TODO scope only children Category (not ModelGroup)
#      c = current_user.categories.find(id).children
#      c = current_user.all_categories.find(id).children
    end
    respond_to do |format|
      format.ext_json { render :json => c.to_json(:methods => [[:text, id], :leaf]) } # .to_a.to_ext_json
    end
  end
  
#######################################################  
  
  def show
    @model = current_user.models.find(params[:id])
    
    @models = [@model]
    c = @models.size
    respond_to do |format|
      format.html { render :partial => 'details' } # TODO remove OR optimize html rendering to extjs
                                  #old# @model.to_json
      format.ext_json { render :json => @models.to_ext_json(:class => "Model",
                                                            :count => c,
                                                            :include => {
                                                                :properties => { :except => [:created_at,
                                                                                             :updated_at] },
                                                                :accessories => { :except => [:model_id] },
                                                                :compatibles => { :records => current_inventory_pools.collect(&:models).flatten.uniq,
                                                                                  :except => [:created_at, 
                                                                                             :updated_at,
                                                                                             :model_id,
                                                                                             :compatible_id] },
                                                                :inventory_pools => { :records => current_inventory_pools,
                                                                                      :methods => [[:items_size, @model.id]], # OPTIMIZE include availability for today?
                                                                                      :only => [:id, :name] },
                                                                :images => { :methods => [:public_filename_thumb],
                                                                             :except => [:created_at,
                                                                                         :updated_at] }
                                                                        }
                                                                 ) }
#TODO#      format.ext_json { render :json => { :model => @model, :inventory_pools => (@model.inventory_pools & current_inventory_pools) } }
    end
  end

end
